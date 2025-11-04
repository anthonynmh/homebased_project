import 'dart:convert';
import 'package:homebased_project/backend/auth_api/auth_service.dart';
import 'package:homebased_project/backend/user_profile_api/user_profile_service.dart';
import 'package:homebased_project/backend/user_profile_api/user_profile_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileRepository {
  UserProfileRepository(this._service);

  final UserProfileService _service;
  UserProfile? _cache;

  Future<UserProfile?> getUserProfile({bool forceRefresh = false}) async {
    // 1️⃣ Return memory cache if available and not forcing refresh
    if (_cache != null && !forceRefresh) {
      // Convert avatar path to signed URL if needed
      if (_cache!.avatarUrl != null && !_cache!.avatarUrl!.startsWith('http')) {
        final signedUrl = await _service.getAvatarUrl(
          authService.currentUserId!,
        );
        _cache = _cache!.copyWith(avatarUrl: signedUrl);
      }
      print('Returning memory cache with avatar URL: ${_cache!.avatarUrl}');
      return _cache;
    }

    // 2️⃣ Try SharedPreferences cache
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString('userProfile');
    if (cachedJson != null && !forceRefresh) {
      var profile = UserProfile.fromMap(jsonDecode(cachedJson));

      // Convert avatar path to signed URL
      if (profile.avatarUrl != null && !profile.avatarUrl!.startsWith('http')) {
        final signedUrl = await _service.getAvatarUrl(
          authService.currentUserId!,
        );
        profile = profile.copyWith(avatarUrl: signedUrl);
      }

      _cache = profile;
      print('Returning cached profile with avatar URL: ${profile.avatarUrl}');
      return _cache;
    }

    // 3️⃣ Fetch from backend
    var profile = await _service.getCurrentUserProfile(
      authService.currentUserId!,
    );
    if (profile != null) {
      // Convert avatar path to signed URL
      if (profile.avatarUrl != null && !profile.avatarUrl!.startsWith('http')) {
        final signedUrl = await _service.getAvatarUrl(
          authService.currentUserId!,
        );
        profile = profile.copyWith(avatarUrl: signedUrl);
      }

      _cache = profile;
      await prefs.setString('userProfile', jsonEncode(profile.toMap()));
      print(
        'Fetched profile from backend with avatar URL: ${profile.avatarUrl}',
      );
    }

    return _cache;
  }

  Future<void> updateUser(UserProfile profile) async {
    await _service.insertCurrentUserProfile(profile);
    _cache = profile;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('userProfile', jsonEncode(profile.toMap()));
  }
}
