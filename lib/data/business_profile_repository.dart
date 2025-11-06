import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:homebased_project/backend/business_profile_api/business_profile_model.dart';
import 'package:homebased_project/backend/business_profile_api/business_profile_service.dart';

class BusinessProfileRepository {
  BusinessProfileRepository(this._service);

  final BusinessProfileService _service;
  BusinessProfile? _cache;

  Future<BusinessProfile?> getBusiness({bool forceRefresh = false}) async {
    if (_cache != null && !forceRefresh) {
      return _cache;
    }

    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString('businessProfile');
    if (cachedJson != null && !forceRefresh) {
      final Map<String, dynamic> map = jsonDecode(cachedJson);
      print('Loaded Business Profile from cache: $map');
      _cache = BusinessProfile.fromMap(map);
      return _cache;
    }

    final profile = await BusinessProfileService.getCurrentBusinessProfile();
    print('is profile null? ${profile == null}');
    if (profile != null) {
      _cache = profile;
      print('Fetched Business Profile: $profile');
      prefs.setString('businessProfile', jsonEncode(profile.toMap()));
    }
    return _cache;
  }

  Future<void> updateBusiness(BusinessProfile profile) async {
    // Temporary: only update SharedPreferences for now
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('businessProfile', jsonEncode(profile.toMap()));
    _cache = profile;

    // Later when backend insert API is ready:
    // await _service.insertCurrentBusinessProfile(profile);
  }
}
