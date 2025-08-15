import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:homebased_project/backend/map_api/map_service.dart';
import 'package:homebased_project/backend/map_api/location_model.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final Color _markerColor = Color.fromARGB(255, 230, 87, 30);

  // List of locations that are displayed as markers

  final List<Location> _locations = [
    Location(name: "Clementi", latitude: 1.3162, longitude: 103.7649),
    Location(name: "National University of Singapore", latitude: 1.2976, longitude: 103.7767),
  ];

  // Function to add new random marker
  void _addRandomLocation() {
    setState(() {
      _locations.add(Location(
        name: "Random Place #${_locations.length + 1}",
        latitude: 1.3162 + (0.01 * _locations.length),
        longitude: 103.7649 + (0.01 * _locations.length),
      ));
    });
  }

  // Function to add a new location marker
  void addLocation({Location? location, String? name, double? lat, double? lng}) {
  setState(() {
    if (location != null) {
      _locations.add(location);
    } else if (name != null && lat != null && lng != null) {
      _locations.add(Location(name: name, latitude: lat, longitude: lng));
    } else {
      // Throw error
    }
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dynamic Markers Map"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location_alt),
            onPressed: _addRandomLocation,
          )
        ],
      ),
      body: MapService.buildMap(MapService.sampleCenter) // Replace with current user geographical location
    );
  }
  }