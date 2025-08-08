import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final List<Map<String, dynamic>> _locations = [
    {
      "name": "Clementi",
      "coords": LatLng(1.3162, 103.7649),
      "color": Colors.red
    },
    {
      "name": "National University of Singapore",
      "coords": LatLng(1.2976, 103.7767),
      "color": Colors.green
    },
  ];

  void _addLocation() {
    setState(() {
      _locations.add({
        "name": "Random Place #${_locations.length + 1}",
        "coords": LatLng(
          1.3162 + (0.01 * _locations.length),
          103.7649 + (0.01 * _locations.length),
        ),
        "color": Colors.purple,
      });
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
            onPressed: _addLocation,
          )
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(1.3404, 103.7090), // Singapore
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: _locations.map((location) {
              return Marker(
                point: location["coords"],
                width: 80,
                height: 80,
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(location["name"])),
                    );
                  },
                  child: Icon(
                    Icons.location_on,
                    color: location["color"],
                    size: 40,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  }