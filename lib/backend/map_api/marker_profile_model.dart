import 'package:latlong2/latlong.dart';

class MarkerProfile {
  final String name;
  final double latitude;
  final double longitude;

  MarkerProfile({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  LatLng getLatLng() {
    return LatLng(latitude, longitude);
  }

}