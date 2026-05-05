import 'dart:math' as math;

import 'package:maplibre_gl/maplibre_gl.dart';

class V2Geo {
  static const LatLng singaporeCenter = LatLng(1.3009, 103.8389);
  static const double radiusKm = 2.0;

  static double distanceKm(LatLng a, LatLng b) {
    const earthRadiusKm = 6371.0;
    final dLat = _degreesToRadians(b.latitude - a.latitude);
    final dLon = _degreesToRadians(b.longitude - a.longitude);
    final lat1 = _degreesToRadians(a.latitude);
    final lat2 = _degreesToRadians(b.latitude);

    final h =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    return 2 * earthRadiusKm * math.asin(math.sqrt(h));
  }

  static LatLng offsetFromCenter({
    required double northMeters,
    required double eastMeters,
  }) {
    final latOffset = northMeters / 111320.0;
    final lonOffset =
        eastMeters /
        (111320.0 * math.cos(_degreesToRadians(singaporeCenter.latitude)));

    return LatLng(
      singaporeCenter.latitude + latOffset,
      singaporeCenter.longitude + lonOffset,
    );
  }

  static List<LatLng> circlePolygon(
    LatLng center,
    double radiusKm, {
    int points = 96,
  }) {
    final coordinates = <LatLng>[];
    final distanceRatio = radiusKm / 6371.0;
    final centerLat = _degreesToRadians(center.latitude);
    final centerLon = _degreesToRadians(center.longitude);

    for (var i = 0; i <= points; i++) {
      final bearing = 2 * math.pi * i / points;
      final lat = math.asin(
        math.sin(centerLat) * math.cos(distanceRatio) +
            math.cos(centerLat) * math.sin(distanceRatio) * math.cos(bearing),
      );
      final lon =
          centerLon +
          math.atan2(
            math.sin(bearing) * math.sin(distanceRatio) * math.cos(centerLat),
            math.cos(distanceRatio) - math.sin(centerLat) * math.sin(lat),
          );

      coordinates.add(LatLng(_radiansToDegrees(lat), _radiansToDegrees(lon)));
    }

    return coordinates;
  }

  static double _degreesToRadians(double value) => value * math.pi / 180;

  static double _radiansToDegrees(double value) => value * 180 / math.pi;
}
