import 'package:flutter/widgets.dart';
import 'package:homebased_project/backend/business_profile_api/business_profile_model.dart';
import 'package:latlong2/latlong.dart';
import 'map_variants_model.dart';

class MapService {
  // Service function for creating a SingleMarkerMap, which updates a dynamic marker's position to where the user clicks.
  static Widget getSingleMarkerMap({
    required LatLng initialCenter,
    void Function(LatLng)? onMarkerChanged,
  }) {
    return SingleMarkerMap(
      initialCenter: initialCenter,
      onMarkerChanged: onMarkerChanged,
    );
  }

  /// Service function that returns a map with a static list of markers.
  static Widget getMultiMarkerMap({
    required LatLng initialCenter,
    required List<BusinessProfile> markerProfiles,
    void Function(BusinessProfile)? onMarkerTapped,
  }) {
    return MultiMarkerMap(
      initialCenter: initialCenter,
      markerProfiles: markerProfiles,
      onMarkerTapped: onMarkerTapped,
    );
  }
}