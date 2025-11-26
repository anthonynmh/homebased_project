import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:homebased_project/mvp2/storefront/storefront_data/storefront_model.dart';

/// Expose business profile related operations
final storefrontService = StorefrontService();

class StorefrontService {
  final SupabaseClient _supabase;
  final bool isTest;
  final String table;
  final String bucket;

  StorefrontService({SupabaseClient? client, this.isTest = false})
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

  /// Insert a new storefront profile (only id and email are required)
  Future<void> insertCurrentStorefront(Storefront profile) {
    try {
      return _supabase.from(table).insert(profile.toMap());
    } catch (e) {
      print('Insert storefront profile error: $e');
      throw Exception('Failed to insert storefront');
    }
  }

  /// Get current user's storefront profile by ID
  Future<Storefront?> getCurrentStorefront(String userId) async {
    try {
      final res = await _supabase
          .from(table)
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (res == null) return null;
      return Storefront.fromMap(res);
    } catch (e) {
      print('Error fetching current storefront: $e');
      return null;
    }
  }

  /// Delete current user's storefront profile by ID
  Future<void> deleteCurrentStorefront(String userId) async {
    try {
      // delete logo from bucket, if any
      await deleteStorefrontLogo(userId);

      // then delete storefront
      await _supabase.from(table).delete().eq('id', userId);
    } catch (e) {
      print('Error deleting current storefront: $e');
    }
  }

  /// Get all Storefronts (useful for listings / marketplace view)
  Future<List<Storefront>> getAllStorefronts() async {
    try {
      final res = await _supabase.from(table).select();

      return (res as List).map((item) => Storefront.fromMap(item)).toList();
    } catch (e) {
      print('Error fetching all storefronts: $e');
      return [];
    }
  }

  /// Update current storefront (only non-null fields will be updated)
  Future<void> updateCurrentStorefront(Storefront profile) async {
    try {
      await _supabase.from(table).update(profile.toMap()).eq('id', profile.id);
      print('Storefront profile updated successfully.');
    } catch (e, st) {
      print('Failed to update storefront profile: $e\n$st');
      throw Exception('Failed to update storefront profile');
    }
  }

  /// Upload storefront logo to Supabase storage and store only file path in table
  Future<void> uploadStorefrontLogo(
    XFile imageFile,
    String userId,
    String updatedAt,
  ) async {
    final filename = 'logo'; // always the same file name for overwrite
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
      Storefront? currentStorefront = await getCurrentStorefront(userId);

      if (currentStorefront != null) {
        currentStorefront.logoUrl = filepath;
        await updateCurrentStorefront(currentStorefront);
        print('Storefront logo uploaded and path stored: $filepath');
      } else {
        throw Exception("No storefront found");
      }
    } catch (e, st) {
      print('Upload Storefront logo error: $e\n$st');
    }
  }

  /// Returns the filepath to the storefront logo (valid for 60 seconds)
  Future<String?> getStorefrontLogoFilepath(String userId) async {
    try {
      final res = await _supabase
          .from(table)
          .select('logo_url')
          .eq('id', userId)
          .maybeSingle();

      final filepath = res?['logo_url'] as String?;

      return filepath;
    } catch (e, st) {
      print('Get storefront logo filepath error: $e\n$st');
      return null;
    }
  }

  /// Returns a signed URL to the storefront logo (valid for 60 seconds)
  Future<String?> getStorefrontLogoSignedUrl(String userId) async {
    try {
      final filepath = await getStorefrontLogoFilepath(userId);
      if (filepath == null) return null;

      final signedUrl = await _supabase.storage
          .from(bucket)
          .createSignedUrl(filepath, 60);

      return signedUrl;
    } catch (e, st) {
      print('Get storefront logo signed URL error: $e\n$st');
      return null;
    }
  }

  Future<void> deleteStorefrontLogo(String userId) async {
    final storage = _supabase.storage;
    final filepath = await getStorefrontLogoFilepath(userId) ?? '';

    try {
      await storage.from(bucket).remove([filepath]);

      // Update DB to remove filepath
      Storefront? currentStorefront = await getCurrentStorefront(userId);

      if (currentStorefront != null) {
        currentStorefront.logoUrl = '';
        currentStorefront.updatedAt = DateTime.now().toUtc().toIso8601String();
        await updateCurrentStorefront(currentStorefront);
      }
    } catch (e) {
      print('Error deleting current storefront logo: $e');
    }
  }

  /// Upload one or more storefront photos to Supabase storage and store file paths in table
  Future<void> uploadStorefrontPhotos(
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
        final filepath = '$userId/storefront_photos/$filename';
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

      print('Storefront photos uploaded: $uploadedPaths');
    } catch (e, st) {
      print('Upload storefront photos error: $e\n$st');
    }
  }

  /// Get signed URLs for all storefront photos
  Future<List<String>> getCurrentStorefrontPhotosUrls(String userId) async {
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
      print('Get storefront photos signed URLs error: $e\n$st');
      return [];
    }
  }
}
