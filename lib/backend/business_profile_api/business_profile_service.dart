import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import 'business_profile_model.dart';

final _client = Supabase.instance.client;

class BusinessProfileService {
  static const String table = 'business_profiles';
  static const String bucket = 'business-photos';

  static Future<BusinessProfile?> getProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      final res = await _client
          .from(table)
          .select()
          .eq('id', user.id)
          .single(); // Returns a Map<String, dynamic>

      // Old API: PostgrestResponse with `data` property
      // New API: Directly returns Map<String, dynamic>
      // The following code handles both instances for version safety, with some VScode complaints
      final Map<String, dynamic>? data = 
        (res is Map<String, dynamic>) ? res : (res as dynamic).data;

      if (data == null) {
        final status = (res is Map) ? null : (res as dynamic).status;
        final statusText = (res is Map) ? null : (res as dynamic).statusText;
        print('Failed to get business profile: $status $statusText');
        return null;
      }

      return BusinessProfile.fromMap(data);
    } catch (error) {
      print('Error getting profile: $error');
      return null;
    }
  }

  static Future<void> upsertProfile(BusinessProfile profile) async {
    await _client
        .from(table)
        .upsert(profile.toMap())
        .then((res) {
          if (res.data == null) {
            print(
              'Failed to upsert business profile: ${res.status} ${res.statusText}',
            );
          } else {
            print('Business profile upserted successfully');
          }
        })
        .catchError((error) {
          print('Error upserting profile: $error');
        });
  }

  static Future<String?> uploadLogo(File imageFile) async {
    final ext = path.extension(imageFile.path);
    final filename = '${const Uuid().v4()}$ext';
    final filepath = 'public/$filename';

    try {
      final response = await _client.storage
          .from(bucket)
          .upload(filepath, imageFile);

      if (response.isEmpty) {
        print('Logo upload failed. No path returned.');
        return null;
      }

      return _client.storage.from(bucket).getPublicUrl(filepath);
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }
}
