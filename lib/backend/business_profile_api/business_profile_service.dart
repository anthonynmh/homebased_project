import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:homebased_project/backend/business_profile_api/business_profile_model.dart';

/// Expose business profile related operations
final userProfileService = BusinessProfileService();

String getEnvVariable(String key) { 
  return Platform.environment.containsKey(key)
      ? Platform.environment[key] ?? ''
      : (dotenv.isInitialized && dotenv.env.containsKey(key)
          ? dotenv.env[key] ?? ''
          : '');
}

final tableProd = getEnvVariable('BUSINESS_PROFILE_TABLE_PROD');
final bucketProd = getEnvVariable('BUSINESS_PROFILE_BUCKET_PROD');

final tableStaging = getEnvVariable('BUSINESS_PROFILE_TABLE_STAGING');
final bucketStaging = getEnvVariable('BUSINESS_PROFILE_BUCKET_STAGING');

// const table = bool.hasEnvironment('BUSINESS_PROFILE_TABLE_PROD')
//     ? String.fromEnvironment('BUSINESS_PROFILE_TABLE_PROD')
//     : '';
// const bucket = bool.hasEnvironment('BUSINESS_PROFILE_BUCKET_PROD')
//     ? String.fromEnvironment('BUSINESS_PROFILE_BUCKET_PROD')
//     : '';

class BusinessProfileService {
  final SupabaseClient _supabase;
  final bool isTest;
  late final table;
  late final bucket;


  BusinessProfileService({SupabaseClient? client, this.isTest = false})
    : _supabase = client ?? Supabase.instance.client {
      table = isTest ? tableStaging : tableProd;
      bucket = isTest ? bucketStaging : bucketProd;
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
      if (profile.sector != null) data['sector'] = profile.sector;
      if (profile.latitude != null) data['latitude'] = profile.latitude;
      if (profile.longitude != null) data['longitude'] = profile.longitude;
      if (profile.logoUrl != null) data['logo_url'] = profile.logoUrl;
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
  Future<void> uploadBusinessLogo(File imageFile, String userId) async {
    final ext = path.extension(imageFile.path);
    final filename = 'logo$ext'; // always the same file name for overwrite
    final filepath = '$userId/logo/$filename';

    try {
      final storage = _supabase.storage;

      // Remove old logo if exists
      try {
        await storage.from(bucket).remove([filepath]);
      } catch (_) {}

      await storage.from(bucket).upload(filepath, imageFile);

      // Update DB with only the file path
      await updateCurrentBusinessProfile(
        BusinessProfile(id: userId, logoUrl: filepath),
        userId,
      );

      print('Business logo uploaded and path stored: $filepath');
    } catch (e, st) {
      print('Upload business logo error: $e\n$st');
    }
  }

  /// Upload one or more business photos to Supabase storage and store file paths in table
  Future<void> uploadBusinessPhotos(
    List<File> imageFiles,
    String userId,
  ) async {
    final storage = _supabase.storage;
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
