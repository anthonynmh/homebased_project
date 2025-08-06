import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import 'user_profile_model.dart';

final _client = Supabase.instance.client;

class UserProfileService {
  static const String table = 'User_Profiles';
  static const String bucket = 'user-profile-photos';

  static Future<UserProfile?> getProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    return await _client.from(table).select().eq('id', user.id).single().then((
      res,
    ) {
      if (res.data == null) {
        print('Get profile failed: ${res.status} - ${res.statusText}');
        return null;
      }
      return UserProfile.fromMap(res.data);
    });
  }

  static Future<void> upsertProfile(UserProfile profile) async {
    await _client.from(table).upsert(profile.toMap()).then((res) {
      if (res.data == null) {
        print('Upsert failed: ${res.status} - ${res.statusText}');
      } else {
        print('Upsert successful');
      }
    });
  }

  static Future<String?> uploadAvatar(File imageFile) async {
    final ext = path.extension(imageFile.path);
    final filename = '${const Uuid().v4()}$ext';
    final filepath = 'public/$filename';

    try {
      final storage = Supabase.instance.client.storage;
      final response = await storage.from(bucket).upload(filepath, imageFile);

      if (response.isEmpty) {
        print('Upload failed. No file URL returned.');
        return null;
      }

      return storage.from(bucket).getPublicUrl(filepath);
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }
}
