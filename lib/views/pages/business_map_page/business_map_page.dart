import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:homebased_project/backend/map_api/map_service.dart';
import 'package:homebased_project/models/business_profile.dart';
import 'package:homebased_project/views/pages/business_map_page/utils/lcoation_permission.dart';
import 'package:latlong2/latlong.dart';

class BusinessMapPage extends StatefulWidget {
  final ValueChanged<String>? onMapChanged;
  final VoidCallback onNext;

  BusinessMapPage({this.onMapChanged, required this.onNext});

  @override
  State<BusinessMapPage> createState() => _BusinessMapPageState();
}

class _BusinessMapPageState extends State<BusinessMapPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Business Map')),
      body: Column(
        children: [
          FutureBuilder<Position>(
            future: determinePosition(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                final position = snapshot.data!;
                print(snapshot.data);
                return Expanded(
                  child: MapService.getSingleMarkerMap(
                    initialCenter: LatLng(
                      position.latitude,
                      position.longitude,
                    ),
                    onMarkerChanged: (p0) {
                      print('OnMarkerChanged called');
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Marker Moved'),
                          content: Text(
                            'New Position: ${p0.latitude}, ${p0.longitude}',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              } else {
                return Center(child: Text('Unable to determine location'));
              }
            },
          ),
          Center(
            child: SizedBox(
              width: 237, // Set your desired width
              height: 74, // Set your desired height
              child: ElevatedButton(
                onPressed: widget.onNext,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: Text(
                  'Continue',
                  style: TextStyle(fontSize: 27, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
