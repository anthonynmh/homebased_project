import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:homebased_project/backend/business_profile_api/business_profile_model.dart';
import 'package:homebased_project/widgets/custom_marker.dart';
import 'package:latlong2/latlong.dart';
import 'map_base_model.dart';

// A map that allows the user to place or update a single marker by tapping on the map.
class SingleMarkerMap extends StatefulWidget {
  final LatLng initialCenter;
  final double zoom;
  final Function(LatLng)? onMarkerChanged;
  final String? logoUrl;
  final bool readOnly; // Callback function for when the marker position changes

  const SingleMarkerMap({
    super.key,
    required this.initialCenter,
    this.zoom = MapBase.defaultZoom,
    this.onMarkerChanged,
    this.logoUrl,
    this.readOnly = false,
  });

  @override
  State<SingleMarkerMap> createState() => _SingleMarkerMapState();
}

class _SingleMarkerMapState extends State<SingleMarkerMap> {
  LatLng? _markerPosition;

  @override
  Widget build(BuildContext context) {
    return MapBase(
      initialCenter: widget.initialCenter,
      initialZoom: widget.zoom,
      dynamicMarkerPosition: _markerPosition,
      markers: [
        Marker(
          point: _markerPosition == null
              ? widget.initialCenter
              : _markerPosition!,
          width: 80,
          height: 80,
          child: CustomMarkerIcon(
            logoPath: widget.logoUrl ?? 'assets/defaultUser.png',
          ),
        ),
      ],
      onTap: widget.readOnly
          ? null
          : (latlng) {
              setState(() {
                _markerPosition = latlng;
              });
              if (widget.onMarkerChanged != null) {
                widget.onMarkerChanged!(latlng);
              }
            },
    );
  }
}

// A map variant that displays a list of static, interactable markers
class MultiMarkerMap extends StatelessWidget {
  final LatLng initialCenter;
  final double zoom;
  final List<BusinessProfile> markerProfiles;
  final Function(BusinessProfile)?
  onMarkerTapped; // Callback function called when a marker is tapped

  const MultiMarkerMap({
    super.key,
    required this.initialCenter,
    this.zoom = MapBase.defaultZoom,
    required this.markerProfiles,
    this.onMarkerTapped,
  });

  @override
  Widget build(BuildContext context) {
    return MapBase(
      initialCenter: initialCenter,
      markers: markerProfiles
          .where(
            (profile) => profile.latitude != null && profile.longitude != null,
          ) // Only display profiles with location
          .map(
            (profile) => Marker(
              point: LatLng(profile.latitude!, profile.longitude!),
              width: 80,
              height: 80,
              child: GestureDetector(
                onTap: () {
                  if (onMarkerTapped != null) {
                    onMarkerTapped!(profile);
                  }
                },
                child: CustomMarkerIcon(
                  logoPath: profile.logoUrl ?? 'assets/defaultUser.png',
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
