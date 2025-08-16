import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:homebased_project/backend/map_api/map_base_model.dart';
import 'package:latlong2/latlong.dart';
import 'package:homebased_project/backend/map_api/map_service.dart';
import 'package:homebased_project/backend/map_api/location_model.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Sample list of locations that are displayed as markers
  final List<Location> _locations = [
    Location(name: "Clementi", latitude: 1.3162, longitude: 103.7649),
    Location(name: "National University of Singapore", latitude: 1.2976, longitude: 103.7767),
  ];

  // Sample initial center 
  final LatLng _sampleCenter = LatLng(1.3162, 103.7649);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dynamic Markers Map"),
      ),
      body: MapBase(initialCenter: _sampleCenter),
    );
  }
}