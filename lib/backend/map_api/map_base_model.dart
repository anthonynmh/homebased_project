import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapBase extends StatelessWidget {
  final LatLng initialCenter;
  final List<Marker> markers;
  final void Function(LatLng)? onTap;

  const MapBase({
    super.key,
    required this.initialCenter,
    this.markers = const [],
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: 13.0,
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


class MapWidget extends StatefulWidget {
  final Function(LatLng)? onTap; // Callback for taps
  final LatLng initialCenter;
  final double initialZoom;
  final LatLng? markerPosition;

  const MapWidget({
    super.key,
    this.onTap,
    required this.initialCenter,
    this.initialZoom = 13,
    this.markerPosition,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final MapController _controller = MapController();
  LatLng? tappedMarker;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _controller,
      options: MapOptions(
        initialCenter: widget.initialCenter,
        initialZoom: widget.initialZoom,
        onTap: (tapPos, latlng) => widget.onTap?.call(latlng),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.homebased-project.app',
        ),
        if (widget.markerPosition != null)
          MarkerLayer(
            markers: [
              Marker(
                point: widget.markerPosition!,
                width: 80,
                height: 80,
                child: const Icon(Icons.location_on, color: Colors.red, size: 40),
              ),
            ],
          ),
      ],
    );
  }
}
