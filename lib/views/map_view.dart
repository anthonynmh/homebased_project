import 'package:flutter/material.dart';
import 'package:homebased_project/backend/business_profile_api/business_profile_model.dart';
import 'package:latlong2/latlong.dart';
import 'package:homebased_project/backend/map_api/map_service.dart';

// Test screen for multimarkermap
class MultiMapScreen extends StatefulWidget {
  const MultiMapScreen({super.key});

  @override
  State<MultiMapScreen> createState() => _MultiMapScreenState();
}

class _MultiMapScreenState extends State<MultiMapScreen> {
  // Sample list of profiles that are used to showcase the type of inputs the MapService takes
  final List<BusinessProfile> _sampleProfiles = [
    BusinessProfile(
      id: "1",
      businessName: "Marina Bay Cafe",
      latitude: 1.2831,
      longitude: 103.8603,
    ),
    BusinessProfile(
      id: "2",
      businessName: "Orchard Bakery",
      latitude: 1.3048,
      longitude: 103.8318,
    ),
    BusinessProfile(
      id: "3",
      businessName: "Sentosa Pizza",
      latitude: 1.2494,
      longitude: 103.8303,
    ),
    BusinessProfile(
      id: "4",
      businessName: "Chinatown Diner",
      latitude: 1.2842,
      longitude: 103.8439,
    ),
    BusinessProfile(
      id: "5",
      businessName: "Little India Spice House",
      latitude: 1.3066,
      longitude: 103.8496,
    ),
  ];

  // Sample initial center
  final LatLng _sampleCenter = LatLng(1.3162, 103.7649);

  // Sample callback function for when a marker is clicked in the map
  void _sampleCallback(BusinessProfile profile) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(profile.businessName!)));
  }

  @override
  Widget build(BuildContext context) {
    // Test for MultiMarkerMap
    return Scaffold(
      appBar: AppBar(title: const Text("Multi Marker Map")),
      body: MapService.getMultiMarkerMap(
        initialCenter: _sampleCenter,
        markerProfiles: _sampleProfiles,
        onMarkerTapped: _sampleCallback,
      ),
    );
  }
}

// Test screen for singlemarkermap
class SingleMapScreen extends StatefulWidget {
  const SingleMapScreen({super.key});

  @override
  State<SingleMapScreen> createState() => _SingleMapScreenState();
}

class _SingleMapScreenState extends State<SingleMapScreen> {
  // Sample initial center
  final LatLng _sampleCenter = LatLng(1.3162, 103.7649);

  @override
  Widget build(BuildContext context) {
    // Test for SingleMarkerMap
    return Scaffold(
      appBar: AppBar(title: const Text("Single Marker Map")),
      body: MapService.getSingleMarkerMap(initialCenter: _sampleCenter),
    );
  }
}
