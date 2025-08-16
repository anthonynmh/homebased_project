import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';
import 'map_variants_model.dart';
import 'marker_profile_model.dart';

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
    required List<MarkerProfile> markerProfiles,
  }) {
    return MultiMarkerMap(
      initialCenter: initialCenter,
      markerProfiles: markerProfiles,
    );
  }
}