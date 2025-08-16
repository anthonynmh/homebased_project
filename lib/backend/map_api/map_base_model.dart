import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapBase extends StatelessWidget {
  final LatLng initialCenter;
  final List<Marker> markers;
  final double initialZoom;
  final LatLng? dynamicMarkerPosition;
  final void Function(LatLng)? onTap;
  static const double defaultZoom = 10.0;

  const MapBase({
    super.key,
    required this.initialCenter,
    this.initialZoom = defaultZoom,
    this.dynamicMarkerPosition,
    this.markers = const [],
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: initialZoom,
        onTap: (_, latlng) => onTap?.call(latlng),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.homebased-project.app',
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }
}
