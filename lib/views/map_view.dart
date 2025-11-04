import 'package:flutter/material.dart';
import 'package:homebased_project/backend/business_profile_api/business_profile_model.dart';
import 'package:homebased_project/views/pages/business_page_customer_pov.dart';
import 'package:latlong2/latlong.dart';
import 'package:homebased_project/backend/map_api/map_service.dart';

// Test screen for multimarkermap
class MultiMapScreen extends StatefulWidget {
  const MultiMapScreen({super.key});

  @override
  State<MultiMapScreen> createState() => _MultiMapScreenState();
}

class _MultiMapScreenState extends State<MultiMapScreen> {
  BusinessProfile? _selectedProfile;
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

  void _onMarkerTapped(BusinessProfile profile) {
    setState(() {
      _selectedProfile = profile;
    });
  }

  void _goToBusinessProfile(BusinessProfile profile) {
    // Navigate to the business profile page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusinessCustomerPage(businessProfile: profile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Find businesses near you!")),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;

          return Stack(
            children: [
              // Base map
              MapService.getMultiMarkerMap(
                initialCenter: _sampleCenter,
                markerProfiles: _sampleProfiles,
                onMarkerTapped: _onMarkerTapped,
              ),

              // Dimmed overlay that captures taps outside the card
              if (_selectedProfile != null)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedProfile = null;
                      });
                    },
                    behavior: HitTestBehavior.opaque,
                    //not too dark
                    child: Container(color: Colors.black.withAlpha(50)),
                  ),
                ),

              // Centered info card
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                top: _selectedProfile != null
                    ? screenHeight / 2 -
                          140 // adjust vertical position
                    : screenHeight,
                left: 20,
                right: 20,
                child: _selectedProfile != null
                    ? GestureDetector(
                        onTap: () {}, // absorb taps on the card itself
                        child: Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            height: 347,
                            width: 323, // adjust card height
                            padding: const EdgeInsets.all(16),
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Logo takes top half
                                    SizedBox(
                                      height: 226.42, // adjust logo height
                                      width: double.infinity,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.asset(
                                          _selectedProfile!.logoUrl ??
                                              'assets/defaultUser.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    // Business name below logo
                                    Text(
                                      _selectedProfile!.businessName ??
                                          'Unnamed',
                                      style: const TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                // Circular button at bottom-right
                                Positioned(
                                  bottom: 12,
                                  right: 12,
                                  child: RawMaterialButton(
                                    onPressed: () =>
                                        _goToBusinessProfile(_selectedProfile!),
                                    fillColor:
                                        Colors.orange, // circular button color
                                    shape:
                                        const CircleBorder(), // makes it a perfect circle
                                    constraints: const BoxConstraints(
                                      minWidth: 39,
                                      minHeight: 39,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white, // arrow color
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          );
        },
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
