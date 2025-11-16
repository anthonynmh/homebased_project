import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:homebased_project/backend/business_profile_api/business_profile_model.dart';

/// Expose business profile related operations
final userProfileService = BusinessProfileService();

class BusinessProfileService {
  final SupabaseClient _supabase;
  final bool isTest;
  final String table;
  final String bucket;

  BusinessProfileService({SupabaseClient? client, this.isTest = false})
    : _supabase = client ?? Supabase.instance.client,
      table = _resolveTable(isTest),
      bucket = _resolveBucket(isTest);

  static String _resolveTable(bool isTest) {
    if (isTest) {
      return dotenv.env["BUSINESS_PROFILE_TABLE_STAGING"] ?? '';
    }
    const prodTable = String.fromEnvironment('BUSINESS_PROFILE_TABLE_PROD');
    return prodTable.isNotEmpty
        ? prodTable
        : dotenv.env["BUSINESS_PROFILE_TABLE_PROD"] ?? '';
  }

  static String _resolveBucket(bool isTest) {
    if (isTest) {
      return dotenv.env["BUSINESS_PROFILE_BUCKET_STAGING"] ?? '';
    }
    const prodBucket = String.fromEnvironment('BUSINESS_PROFILE_BUCKET_PROD');
    return prodBucket.isNotEmpty
        ? prodBucket
        : dotenv.env["BUSINESS_PROFILE_BUCKET_PROD"] ?? '';
  }

  /// Insert a new business profile (only id and email are required)
  Future<void> insertCurrentBusinessProfile(BusinessProfile profile) {
    try {
      return _supabase.from(table).insert(profile.toMap());
    } catch (e) {
      print('Insert business profile error: $e');
      throw Exception('Failed to insert business profile');
    }
  }

  /// Get current user's business profile by ID
  Future<BusinessProfile?> getCurrentBusinessProfile(String userId) async {
    try {
      final res = await _supabase
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
  Future<List<BusinessProfile>> getAllBusinessProfiles() async {
    try {
      final res = await _supabase.from(table).select();

      return (res as List)
          .map((item) => BusinessProfile.fromMap(item))
          .toList();
    } catch (e) {
      print('Error fetching all business profiles: $e');
      return [];
    }
  }

  /// Update current business profile (only non-null fields will be updated)
  Future<void> updateCurrentBusinessProfile(
    BusinessProfile profile,
    String userId,
  ) async {
    try {
      final data = <String, dynamic>{};
      if (profile.businessName != null) {
        data['business_name'] = profile.businessName;
      }
      if (profile.description != null) {
        data['description'] = profile.description;
      }
      data['updated_at'] = DateTime.now().toUtc().toIso8601String();

      if (data.isEmpty) return;

      await _supabase.from(table).update(data).eq('id', userId);
      print('Business profile updated successfully.');
    } catch (e, st) {
      print('Failed to update business profile: $e\n$st');
      throw Exception('Failed to update business profile');
    }
  }

  /// Upload business logo to Supabase storage and store only file path in table
  Future<void> uploadBusinessLogo(
    XFile imageFile,
    String userId,
    String businessName,
    String updatedAt,
  ) async {
    final ext = path.extension(imageFile.name);
    final filename = 'logo$ext'; // always the same file name for overwrite
    final filepath = '$userId/logo/$filename';

    try {
      final storage = _supabase.storage;
      final bytes = await imageFile.readAsBytes();

      // Remove old logo if exists
      try {
        await storage.from(bucket).remove([filepath]);
      } catch (_) {}

      await storage.from(bucket).uploadBinary(filepath, bytes);

      // Update DB with only the file path
      await updateCurrentBusinessProfile(
        BusinessProfile(
          id: userId,
          businessName: businessName,
          updatedAt: updatedAt,
        ),
        userId,
      );

      print('Business logo uploaded and path stored: $filepath');
    } catch (e, st) {
      print('Upload business logo error: $e\n$st');
    }
  }

  /// Upload one or more business photos to Supabase storage and store file paths in table
  Future<void> uploadBusinessPhotos(
    List<XFile> imageFiles,
    String userId,
  ) async {
    final storage = _supabase.storage;
    final List<String> uploadedPaths = [];

    try {
      for (final imageFile in imageFiles) {
        final ext = path.extension(imageFile.name);
        final basename = path.basenameWithoutExtension(imageFile.name);
        final filename =
            '${basename}_${DateTime.now().millisecondsSinceEpoch}$ext'; // avoid collisions
        final filepath = '$userId/business_photos/$filename';
        var bytes = await imageFile.readAsBytes();

        await storage.from(bucket).uploadBinary(filepath, bytes);
        uploadedPaths.add(filepath);
      }

      // Fetch existing photos
      final existingRes = await _supabase
          .from(table)
          .select('photo_urls')
          .eq('id', userId)
          .maybeSingle();

      List<String> existingPaths = [];
      if (existingRes != null && existingRes['photo_urls'] != null) {
        existingPaths = List<String>.from(
          existingRes['photo_urls'] as List<dynamic>,
        );
      }

      // Merge new + existing
      final updatedPaths = [...existingPaths, ...uploadedPaths];

      // Update DB with all photo paths
      await _supabase
          .from(table)
          .update({'photo_urls': updatedPaths})
          .eq('id', userId);

      print('Business photos uploaded: $uploadedPaths');
    } catch (e, st) {
      print('Upload business photos error: $e\n$st');
    }
  }

  /// Get signed URLs for all business photos
  Future<List<String>> getCurrentBusinessPhotosUrls(String userId) async {
    try {
      final res = await _supabase
          .from(table)
          .select('photo_urls')
          .eq('id', userId)
          .maybeSingle();

      final List<dynamic>? paths = res?['photo_urls'] as List<dynamic>?;
      if (paths == null || paths.isEmpty) return [];

      final List<String> signedUrls = [];
      for (final filepath in paths) {
        final url = await _supabase.storage
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
  Future<String?> getCurrentBusinessLogoUrl(String userId) async {
    try {
      final res = await _supabase
          .from(table)
          .select('logo_url')
          .eq('id', userId)
          .maybeSingle();

      final filepath = res?['logo_url'] as String?;
      if (filepath == null) return null;

      final signedUrl = await _supabase.storage
          .from(bucket)
          .createSignedUrl(filepath, 60);

      return signedUrl;
    } catch (e, st) {
      print('Get business logo signed URL error: $e\n$st');
      return null;
    }
  }

  /// Example: Search business profiles by sector
  Future<List<BusinessProfile>> searchBusinessProfilesBySector(
    String sector,
  ) async {
    try {
      final res = await _supabase.from(table).select().eq('sector', sector);

      return (res as List)
          .map((item) => BusinessProfile.fromMap(item))
          .toList();
    } catch (e) {
      print('Error searching business profiles by sector: $e');
      return [];
    }
  }
}
