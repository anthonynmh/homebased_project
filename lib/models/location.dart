import 'package:latlong2/latlong.dart';

class Location {
  final String name;
  final double latitude;
  final double longitude;

  Location({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  LatLng getLatLng() {
    return LatLng(latitude, longitude);
  }

}