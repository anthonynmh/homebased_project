import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:homebased_project/backend/user_profile_api/user_profile_model.dart';

/// Expose user profile related operations
final userProfileService = UserProfileService();

const table = bool.hasEnvironment('USER_PROFILE_TABLE_PROD')
    ? String.fromEnvironment('USER_PROFILE_TABLE_PROD')
    : '';
const bucket = bool.hasEnvironment('USER_PROFILE_BUCKET_PROD')
    ? String.fromEnvironment('USER_PROFILE_BUCKET_PROD')
    : '';

class UserProfileService {
  final SupabaseClient _supabase;
  final bool isTest;

  UserProfileService({SupabaseClient? client, this.isTest = false})
    : _supabase = client ?? Supabase.instance.client;

  /// Table and bucket names depend on environment
  // late const String table;
  // late final String bucket;

  // UserProfileService({SupabaseClient? client, this.isTest = false})
  //   : _supabase = client ?? Supabase.instance.client {
  //   if (isTest) {
  //     // Use staging table and bucket
  //     const table = bool.hasEnvironment('USER_PROFILE_TABLE_STAGING')
  //         ? String.fromEnvironment('USER_PROFILE_TABLE_STAGING')
  //         : '';
  //     const bucket = bool.hasEnvironment('USER_PROFILE_BUCKET_STAGING')
  //         ? String.fromEnvironment('USER_PROFILE_BUCKET_STAGING')
  //         : '';

  //     if (table.isEmpty || bucket.isEmpty) {
  //       throw Exception(
  //         'User profile table or bucket is not set in environment.',
  //       );
  //     }
  //   } else {
  //     // Use production table and bucket
  //     const table = bool.hasEnvironment('USER_PROFILE_TABLE_PROD')
  //         ? String.fromEnvironment('USER_PROFILE_TABLE_PROD')
  //         : '';
  //     const bucket = bool.hasEnvironment('USER_PROFILE_BUCKET_PROD')
  //         ? String.fromEnvironment('USER_PROFILE_BUCKET_PROD')
  //         : '';

  //     if (table.isEmpty || bucket.isEmpty) {
  //       throw Exception(
  //         'User profile table or bucket is not set in environment.',
  //       );
  //     }
  //   }
  // }

  /// Get profile by supabase id (unique user ID)
  Future<UserProfile?> getCurrentUserProfile(String userId) async {
    try {
      final res = await _supabase
          .from(table)
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (res == null) return null;
      return UserProfile.fromMap(res);
    } catch (e) {
      print('supabase lookup error: $e');
      return null;
    }
  }

  Future<void> insertCurrentUserProfile(
    UserProfile profile, {
    bool isTest = false,
  }) async {
    final rpcName = isTest ? 'create_profile_staging' : 'create_profile';

    try {
      await _supabase.rpc(
        rpcName,
        params: {'p_id': profile.id, 'p_email': profile.email},
      );

      print('✅ User profile inserted successfully.');
    } catch (e, stackTrace) {
      print("❌ RPC '$rpcName' failed: $e");
      print(stackTrace);
    }
  }

  Future<void> updateCurrentUserProfile(UserProfile profile) async {
    if (profile.id.isEmpty) {
      throw Exception('Profile ID is required for update.');
    }

    try {
      // Build a map of only the fields that are not null
      final data = <String, dynamic>{};
      if (profile.username != null) data['username'] = profile.username;
      if (profile.fullName != null) data['full_name'] = profile.fullName;
      if (profile.avatarUrl != null) data['avatar_url'] = profile.avatarUrl;
      if (profile.email != null) data['email'] = profile.email;
      data['updated_at'] = DateTime.now().toUtc().toIso8601String();

      if (data.isEmpty) return; // nothing to update

      final res = await _supabase
          .from(table)
          .update(data)
          .eq('id', profile.id)
          .select();

      if (res.isEmpty) {
        throw Exception(
          'No profile found, or you do not have permission to update it.',
        );
      }
    } catch (e, st) {
      print('Failed to update user profile: $e\n$st');
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Upload avatar image to Supabase storage and store only the file path in table
  Future<void> uploadAvatar(File imageFile, String userId) async {
    final ext = path.extension(imageFile.path);
    final filename = 'avatar$ext'; // unique per user
    final filepath = '$userId/$filename';

    try {
      final storage = _supabase.storage;

      // Remove old avatar if it exists
      try {
        await storage.from(bucket).remove([filepath]);
      } catch (_) {
        // ignore if none exists
      }

      await storage.from(bucket).upload(filepath, imageFile);

      // Store only the file path (not public URL)
      await updateCurrentUserProfile(
        UserProfile(id: userId, avatarUrl: filepath),
      );

      print('Avatar uploaded and path stored: $filepath');
    } catch (e, st) {
      print('Upload avatar error: $e\n$st');
    }
  }

  /// Deletes the current user's avatar from storage and clears the avatar_url field
  Future<void> deleteAvatar(String userId) async {
    try {
      final profile = await getCurrentUserProfile(userId);
      final avatarPath = profile?.avatarUrl;
      if (avatarPath == null) return; // no avatar to delete

      final storage = _supabase.storage;

      // Remove avatar file from storage
      await storage.from(bucket).remove([avatarPath]);

      // Clear avatar_url field in profile
      await updateCurrentUserProfile(UserProfile(id: userId, avatarUrl: null));

      print('Avatar deleted successfully.');
    } catch (e, st) {
      print('Delete avatar error: $e\n$st');
    }
  }

  /// Returns a signed URL to the current user's avatar (or null if none exists).
  Future<String?> getAvatarUrl(String userId) async {
    try {
      final res = await _supabase
          .from(table)
          .select('avatar_url')
          .eq('id', userId)
          .maybeSingle();

      final path = res?['avatar_url'] as String?;
      if (path == null) return null;

      // Generate signed URL valid for 60 seconds
      final signedUrl = await _supabase.storage
          .from(bucket)
          .createSignedUrl(path, 60);

      return signedUrl;
    } catch (e, st) {
      print('Get avatar signed URL error: $e\n$st');
      return null;
    }
  }
}
