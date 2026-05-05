import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'package:homebased_project/v2/models/v2_listing.dart';
import 'package:homebased_project/v2/utils/v2_geo.dart';

class V2ListingMap extends StatefulWidget {
  final LatLng currentLocation;
  final List<V2Listing> listings;
  final V2Listing? selectedListing;
  final bool Function(String listingId) isSubscribed;
  final void Function(String listingId) onListingSelected;

  const V2ListingMap({
    super.key,
    required this.currentLocation,
    required this.listings,
    required this.selectedListing,
    required this.isSubscribed,
    required this.onListingSelected,
  });

  @override
  State<V2ListingMap> createState() => _V2ListingMapState();
}

class _V2ListingMapState extends State<V2ListingMap> {
  static const _styleUrl = 'https://tiles.openfreemap.org/styles/positron';

  MapLibreMapController? _mapController;
  bool _styleLoaded = false;
  bool _syncing = false;
  bool _syncAgain = false;
  String? _lastFingerprint;
  String? _errorText;

  @override
  void didUpdateWidget(covariant V2ListingMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_syncAnnotations());
      if (oldWidget.selectedListing?.id != widget.selectedListing?.id) {
        unawaited(_easeToSelectedListing());
      }
    });
  }

  @override
  void dispose() {
    _mapController?.onCircleTapped.remove(_handleCircleTapped);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MapLibreMap(
          initialCameraPosition: CameraPosition(
            target: widget.currentLocation,
            zoom: 14.35,
          ),
          styleString: _styleUrl,
          logoEnabled: false,
          compassEnabled: false,
          attributionButtonPosition: AttributionButtonPosition.bottomLeft,
          annotationOrder: const [
            AnnotationType.fill,
            AnnotationType.line,
            AnnotationType.circle,
            AnnotationType.symbol,
          ],
          onMapCreated: (controller) {
            _mapController = controller;
            controller.onCircleTapped.add(_handleCircleTapped);
          },
          onStyleLoadedCallback: () {
            setState(() => _styleLoaded = true);
            unawaited(_syncAnnotations(force: true));
          },
        ),
        if (!_styleLoaded)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x33FFFFFF),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        if (_errorText != null)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 14,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  _errorText!,
                  style: const TextStyle(
                    color: Color(0xFF9A3412),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _syncAnnotations({bool force = false}) async {
    final controller = _mapController;
    if (!_styleLoaded || controller == null) return;

    final fingerprint = _fingerprint();
    if (!force && fingerprint == _lastFingerprint) return;

    if (_syncing) {
      _syncAgain = true;
      return;
    }

    _syncing = true;

    try {
      await controller.clearFills();
      await controller.clearLines();
      await controller.clearCircles();

      final radius = V2Geo.circlePolygon(
        widget.currentLocation,
        V2Geo.radiusKm,
      );

      await controller.addFill(
        FillOptions(
          geometry: [radius],
          fillColor: '#176B87',
          fillOpacity: 0.07,
          fillOutlineColor: '#176B87',
        ),
      );
      await controller.addLine(
        LineOptions(
          geometry: radius,
          lineColor: '#176B87',
          lineOpacity: 0.62,
          lineWidth: 1.8,
        ),
      );
      await controller.addCircle(
        CircleOptions(
          geometry: widget.currentLocation,
          circleRadius: 8,
          circleColor: '#17201D',
          circleOpacity: 1,
          circleStrokeColor: '#FFFFFF',
          circleStrokeWidth: 3,
          circleStrokeOpacity: 1,
        ),
      );

      final listingCircles = <CircleOptions>[];
      final circleData = <Map<String, Object>>[];
      final orderedListings = [
        ...widget.listings.where(
          (listing) => listing.id != widget.selectedListing?.id,
        ),
        ...widget.listings.where(
          (listing) => listing.id == widget.selectedListing?.id,
        ),
      ];

      for (final listing in orderedListings) {
        final isSelected = listing.id == widget.selectedListing?.id;
        final isSubscribed = widget.isSubscribed(listing.id);
        final color = listing.ownedByCurrentLister
            ? '#D97706'
            : isSelected
            ? '#E11D48'
            : isSubscribed
            ? '#6D28D9'
            : '#176B87';

        listingCircles.add(
          CircleOptions(
            geometry: listing.location,
            circleRadius: isSelected ? 13 : 10,
            circleColor: color,
            circleOpacity: 0.98,
            circleStrokeColor: '#FFFFFF',
            circleStrokeWidth: isSelected ? 4 : 3,
            circleStrokeOpacity: 1,
          ),
        );
        circleData.add({'listingId': listing.id});
      }

      if (listingCircles.isNotEmpty) {
        await controller.addCircles(listingCircles, circleData);
      }

      _lastFingerprint = fingerprint;
      if (mounted && _errorText != null) {
        setState(() => _errorText = null);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _errorText = 'Map markers could not be refreshed.');
      }
    } finally {
      _syncing = false;
      if (_syncAgain) {
        _syncAgain = false;
        unawaited(_syncAnnotations(force: true));
      }
    }
  }

  String _fingerprint() {
    final selectedId = widget.selectedListing?.id ?? 'none';
    final listingState = widget.listings
        .map(
          (listing) =>
              '${listing.id}:${listing.interestCount}:'
              '${listing.ownedByCurrentLister}:'
              '${widget.isSubscribed(listing.id)}',
        )
        .join('|');
    return '$selectedId|$listingState';
  }

  Future<void> _easeToSelectedListing() async {
    final controller = _mapController;
    final selected = widget.selectedListing;
    if (!_styleLoaded || controller == null || selected == null) return;

    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(selected.location, 14.55),
    );
  }

  void _handleCircleTapped(Circle circle) {
    final listingId = circle.data?['listingId'] as String?;
    if (listingId == null) return;
    widget.onListingSelected(listingId);
  }
}
