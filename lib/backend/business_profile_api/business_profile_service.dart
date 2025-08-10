import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

import 'package:homebased_project/backend/business_profile_api/business_profile_model.dart';
import 'package:homebased_project/providers/auth_state.dart' as auth_provider;

final _client = Supabase.instance.client;

class BusinessProfileService {
  static const String table = 'Business_Profiles';
  static const String bucket = 'business-photos';

  // Get the current business profile for the logged-in user
  static Future<BusinessProfile?> getProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      print('No authenticated user found.');
      return null;
    }

    try {
      final res = await _client
          .from(table)
          .select()
          .eq('id', user.id)
          .maybeSingle(); // returns Map<String, dynamic>? or null

      if (res == null) {
        print('No business profile found for user ${user.id}');
        return null;
      }

      return BusinessProfile.fromMap(res);
    } on PostgrestException catch (e) {
      print('Error getting business profile: ${e.message}');
      return null;
    } catch (e) {
      print('Unexpected error getting business profile: $e');
      return null;
    }
  }

  // Create or update a business profile
  static Future<bool> upsertProfile(
    Map<String, dynamic> profileData,
    auth_provider.AuthState authState,
  ) async {
    final credentials = authState.credentials;
    if (credentials == null) {
      print('User not logged in, cannot upsert profile.');
      return false;
    }

    final auth0Sub = credentials.user.sub;
    if (auth0Sub == null) {
      print('auth0Sub is null — cannot upsert profile.');
      return false;
    }

    // Add auth0_sub to the map
    final dataToUpsert = Map<String, dynamic>.from(profileData)
      ..['auth0_sub'] = auth0Sub;

    try {
      final res = await _client
          .from(table)
          .upsert(dataToUpsert)
          .select()
          .maybeSingle();

      if (res == null) {
        print('Upsert returned no data — possible failure.');
        return false;
      }

      print('Business profile upserted successfully.');
      return true;
    } on PostgrestException catch (e) {
      print('Error upserting business profile: ${e.message}');
      return false;
    } catch (e) {
      print('Unexpected error upserting business profile: $e');
      return false;
    }
  }

  // Uploads a logo image to storage and returns the public URL
  static Future<String?> uploadLogo(File imageFile) async {
    final ext = path.extension(imageFile.path);
    final filename = '${const Uuid().v4()}$ext';
    final filepath = 'public/$filename';

    try {
      final response = await _client.storage
          .from(bucket)
          .upload(filepath, imageFile);

      if (response.isEmpty) {
        print('Logo upload failed — no path returned.');
        return null;
      }

      final publicUrl = _client.storage.from(bucket).getPublicUrl(filepath);
      print('Logo uploaded successfully: $publicUrl');
      return publicUrl;
    } on StorageException catch (e) {
      print('Storage error: ${e.message}');
      return null;
    } catch (e) {
      print('Unexpected upload error: $e');
      return null;
    }
  }
}
