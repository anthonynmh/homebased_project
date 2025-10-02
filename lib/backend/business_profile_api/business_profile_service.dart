import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart' as path;

import 'package:homebased_project/backend/supabase_api/supabase_service.dart';
import 'package:homebased_project/backend/auth_api/auth_service.dart';
import 'package:homebased_project/backend/business_profile_api/business_profile_model.dart';

class BusinessProfileService {
  static final String table = dotenv.env['BUSINESS_PROFILE_TABLE_PROD'] ?? '';
  static final String bucket = dotenv.env['BUSINESS_PROFILE_BUCKET_PROD'] ?? '';

  static String get _currentUserId {
    final id = authService.currentUserId;
    if (id == null) throw Exception('No user is currently logged in.');
    return id;
  }

  /// Get current user's business profile by ID
  static Future<BusinessProfile?> getCurrentBusinessProfile() async {
    final userId = _currentUserId;
    try {
      final res = await supabase
          .from(table)
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (res == null) return null;
      return BusinessProfile.fromMap(res);
    } catch (e) {
      print('Error fetching current business profile: $e');
      return null;
    }
  }

  /// Get all business profiles (useful for listings / marketplace view)
  static Future<List<BusinessProfile>> getAllBusinessProfiles() async {
    try {
      final res = await supabase.from(table).select();

      return (res as List)
          .map((item) => BusinessProfile.fromMap(item))
          .toList();
    } catch (e) {
      print('Error fetching all business profiles: $e');
      return [];
    }
  }

  /// Update current business profile (only non-null fields will be updated)
  static Future<void> updateCurrentBusinessProfile(
    BusinessProfile profile,
  ) async {
    final userId = _currentUserId;

    try {
      final data = <String, dynamic>{};
      if (profile.businessName != null) {
        data['business_name'] = profile.businessName;
      }
      if (profile.description != null) {
        data['description'] = profile.description;
      }
      if (profile.sector != null) data['sector'] = profile.sector;
      if (profile.latitude != null) data['latitude'] = profile.latitude;
      if (profile.longitude != null) data['longitude'] = profile.longitude;
      if (profile.logoUrl != null) data['logo_url'] = profile.logoUrl;
      data['updated_at'] = DateTime.now().toUtc().toIso8601String();

      if (data.isEmpty) return;

      await supabase.from(table).update(data).eq('id', userId);
      print('Business profile updated successfully.');
    } catch (e, st) {
      print('Failed to update business profile: $e\n$st');
      throw Exception('Failed to update business profile');
    }
  }

  /// Upload business logo to Supabase storage and store only file path in table
  static Future<void> uploadBusinessLogo(File imageFile) async {
    final userId = _currentUserId;
    final ext = path.extension(imageFile.path);
    final filename = 'logo$ext'; // always the same file name for overwrite
    final filepath = '$userId/logo/$filename';

    try {
      final storage = supabase.storage;

      // Remove old logo if exists
      try {
        await storage.from(bucket).remove([filepath]);
      } catch (_) {}

      await storage.from(bucket).upload(filepath, imageFile);

      // Update DB with only the file path
      await updateCurrentBusinessProfile(
        BusinessProfile(id: userId, logoUrl: filepath),
      );

      print('Business logo uploaded and path stored: $filepath');
    } catch (e, st) {
      print('Upload business logo error: $e\n$st');
    }
  }

  /// Upload one or more business photos to Supabase storage and store file paths in table
  static Future<void> uploadBusinessPhotos(List<File> imageFiles) async {
    final userId = _currentUserId;
    final storage = supabase.storage;

    final List<String> uploadedPaths = [];

    try {
      for (final imageFile in imageFiles) {
        final ext = path.extension(imageFile.path);
        final basename = path.basenameWithoutExtension(imageFile.path);
        final filename =
            '${basename}_${DateTime.now().millisecondsSinceEpoch}$ext'; // avoid collisions
        final filepath = '$userId/business_photos/$filename';

        await storage.from(bucket).upload(filepath, imageFile);
        uploadedPaths.add(filepath);
      }

      // Fetch existing photos
      final existingRes = await supabase
          .from(table)
          .select('business_photos')
          .eq('id', userId)
          .maybeSingle();

      List<String> existingPaths = [];
      if (existingRes != null && existingRes['business_photos'] != null) {
        existingPaths = List<String>.from(
          existingRes['business_photos'] as List<dynamic>,
        );
      }

      // Merge new + existing
      final updatedPaths = [...existingPaths, ...uploadedPaths];

      // Update DB with all photo paths
      await supabase
          .from(table)
          .update({'business_photos': updatedPaths})
          .eq('id', userId);

      print('Business photos uploaded: $uploadedPaths');
    } catch (e, st) {
      print('Upload business photos error: $e\n$st');
    }
  }

  /// Get signed URLs for all business photos
  static Future<List<String>> getCurrentBusinessPhotosUrls() async {
    final userId = _currentUserId;

    try {
      final res = await supabase
          .from(table)
          .select('business_photos')
          .eq('id', userId)
          .maybeSingle();

      final List<dynamic>? paths = res?['business_photos'] as List<dynamic>?;
      if (paths == null || paths.isEmpty) return [];

      final List<String> signedUrls = [];
      for (final filepath in paths) {
        final url = await supabase.storage
            .from(bucket)
            .createSignedUrl(filepath, 60);
        signedUrls.add(url);
      }

      return signedUrls;
    } catch (e, st) {
      print('Get business photos signed URLs error: $e\n$st');
      return [];
    }
  }

  /// Returns a signed URL to the business logo (valid for 60 seconds)
  static Future<String?> getCurrentBusinessLogoUrl() async {
    final userId = _currentUserId;

    try {
      final res = await supabase
          .from(table)
          .select('logo_url')
          .eq('id', userId)
          .maybeSingle();

      final filepath = res?['logo_url'] as String?;
      if (filepath == null) return null;

      final signedUrl = await supabase.storage
          .from(bucket)
          .createSignedUrl(filepath, 60);

      return signedUrl;
    } catch (e, st) {
      print('Get business logo signed URL error: $e\n$st');
      return null;
    }
  }

  /// Example: Search business profiles by sector
  static Future<List<BusinessProfile>> searchBusinessProfilesBySector(
    String sector,
  ) async {
    try {
      final res = await supabase.from(table).select().eq('sector', sector);

      return (res as List)
          .map((item) => BusinessProfile.fromMap(item))
          .toList();
    } catch (e) {
      print('Error searching business profiles by sector: $e');
      return [];
    }
  }
}
