import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart' as path;

import 'package:homebased_project/backend/supabase_api/supabase_service.dart';
import 'package:homebased_project/backend/auth_api/auth_service.dart';
import 'package:homebased_project/backend/user_profile_api/user_profile_model.dart';

class UserProfileService {
  static final String table = dotenv.env['USER_PROFILE_TABLE_PROD'] ?? '';
  static final String bucket = dotenv.env['USER_PROFILE_BUCKET_PROD'] ?? '';

  static String get _currentUserId {
    final id = authService.currentUserId;
    if (id == null) throw Exception('No user is currently logged in.');
    return id;
  }

  /// Get profile by supabase id (unique user ID)
  static Future<UserProfile?> getCurrentUserProfile() async {
    final userId = _currentUserId;

    try {
      final res = await supabase
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

  static Future<void> insertCurrentUserProfile(UserProfile profile) async {
    try {
      await supabase.rpc(
        'create_profile',
        params: {'p_id': profile.id, 'p_email': profile.email},
      );

      print('User profile inserted successfully.');
    } catch (e) {
      print('RPC create_profile failed: $e');
    }
  }

  static Future<void> updateCurrentUserProfile(UserProfile profile) async {
    final userId = _currentUserId;

    try {
      // Build a map of only the fields that are not null
      final data = <String, dynamic>{};
      if (profile.username != null) data['username'] = profile.username;
      if (profile.fullName != null) data['full_name'] = profile.fullName;
      if (profile.avatarUrl != null) data['avatar_url'] = profile.avatarUrl;
      if (profile.email != null) data['email'] = profile.email;
      data['updated_at'] = DateTime.now().toUtc().toIso8601String();

      if (data.isEmpty) return; // nothing to update

      await supabase.from(table).update(data).eq('id', userId);
    } catch (e, st) {
      print('Failed to update user profile: $e\n$st');
      throw Exception('Failed to update profile');
    }
  }

  /// Upload avatar image to Supabase storage and store only the file path in table
  static Future<void> uploadAvatar(File imageFile) async {
    final userId = _currentUserId;

    final ext = path.extension(imageFile.path);
    final filename = '$userId$ext'; // unique per user
    final filepath = filename;

    try {
      final storage = supabase.storage;

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

  /// Returns a signed URL to the current user's avatar (or null if none exists).
  static Future<String?> getAvatarUrl() async {
    final userId = _currentUserId;

    try {
      final res = await supabase
          .from(table)
          .select('avatar_url')
          .eq('id', userId)
          .maybeSingle();

      final path = res?['avatar_url'] as String?;
      if (path == null) return null;

      // Generate signed URL valid for 60 seconds
      final signedUrl = await supabase.storage
          .from(bucket)
          .createSignedUrl(path, 60);

      return signedUrl;
    } catch (e, st) {
      print('Get avatar signed URL error: $e\n$st');
      return null;
    }
  }
}
