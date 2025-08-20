import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import 'user_profile_model.dart';

final _client = Supabase.instance.client;

class UserProfileService {
  static const String table = 'User_Profiles';
  static const String bucket = 'user-profile-photos';

  /// Insert profile only for new signups (no conflict handling)
  static Future<void> createProfileFromAuth0({
    required String auth0Sub,
    required String email,
    String name = '',
  }) async {
    if (auth0Sub.isEmpty || email.isEmpty) {
      print('Invalid Auth0 data: cannot create profile');
      return;
    }

    final profile = {
      'auth0_sub': auth0Sub,
      'email': email,
      'name': name,
      // created_at and profile_photo_url handled by DB defaults
    };

    try {
      final res = await _client
          .from(table)
          .insert(profile)
          .select()
          .single(); // Throws if > 1 or 0 rows

      print('Profile created: $res');
    } on PostgrestException catch (e) {
      print('Insert failed: ${e.message}');
    } catch (e) {
      print('Unexpected error: $e');
    }
  }

  /// Get profile by Auth0 sub (unique user ID)
  static Future<UserProfile?> getProfileByAuth0Sub(String auth0Sub) async {
    try {
      final res = await _client
          .from(table)
          .select()
          .eq('auth0_sub', auth0Sub)
          .maybeSingle();

      if (res == null) return null;
      return UserProfile.fromMap(res);
    } catch (e) {
      print('supabase lookup error: $e');
      return null;
    }
  }

  /// Upload avatar image to Supabase storage and return public URL
  static Future<String?> uploadAvatar(File imageFile) async {
    final ext = path.extension(imageFile.path);
    final filename = '${const Uuid().v4()}$ext';
    final filepath = 'public/$filename';

    try {
      final storage = _client.storage;
      await storage.from(bucket).upload(filepath, imageFile);

      return storage.from(bucket).getPublicUrl(filepath);
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }
}
