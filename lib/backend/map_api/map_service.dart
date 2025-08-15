import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';
import 'map_model.dart';

class MapService {
  static const LatLng sampleCenter = LatLng(1.3162, 103.7649);

  static Widget buildMap(LatLng initialCenter) {
    return MapWidget(
      initialCenter: initialCenter,
    );
  }
}

// body: FlutterMap(
      //   mapController: _mapController,
      //   options: MapOptions(
      //     initialCenter: LatLng(1.3404, 103.7090), // Singapore
      //     initialZoom: 13.0,
      //   ),
      //   children: [
      //     TileLayer(
      //       urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      //       userAgentPackageName: 'com.example.app',
      //     ),
      //     // Key here is that the markerlayer should be handled by the backend api? or just the location info
      //     MarkerLayer(
      //       markers: _locations.map((location) {
      //         return Marker(
      //           point: location.getLatLng(),
      //           width: 80,
      //           height: 80,
      //           child: GestureDetector(
      //             onTap: () {
      //               ScaffoldMessenger.of(context).showSnackBar(
      //                 SnackBar(content: Text(location.name)),
      //               );
      //             },
      //             child: Icon(
      //               Icons.location_on,
      //               color: _markerColor,
      //               size: 40,
      //             ),
      //           ),
      //         );
      //       }).toList(),
      //     ),
      //   ],
      // ),