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

    final res = await _client.from(table).insert(profile);

    if (res.error != null) {
      print('Insert failed: ${res.error!.message}');
    } else {
      print('Profile created');
    }
  }

  /// Get profile by Auth0 sub (unique user ID)
  static Future<UserProfile?> getProfileByAuth0Sub(String auth0Sub) async {
    final res = await _client
        .from(table)
        .select()
        .eq('auth0_sub', auth0Sub)
        .maybeSingle();

    if (res == null) return null;
    return UserProfile.fromMap(res);
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
