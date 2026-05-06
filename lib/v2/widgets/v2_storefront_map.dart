import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'package:homebased_project/v2/models/v2_marketplace.dart';
import 'package:homebased_project/v2/utils/v2_geo.dart';

class V2StorefrontMap extends StatefulWidget {
  final LatLng currentLocation;
  final List<V2Storefront> storefronts;
  final V2Storefront? selectedStorefront;
  final bool Function(String storefrontId) isSubscribed;
  final bool Function(String storefrontId) canManage;
  final void Function(String storefrontId) onStorefrontSelected;

  const V2StorefrontMap({
    super.key,
    required this.currentLocation,
    required this.storefronts,
    required this.selectedStorefront,
    required this.isSubscribed,
    required this.canManage,
    required this.onStorefrontSelected,
  });

  @override
  State<V2StorefrontMap> createState() => _V2StorefrontMapState();
}

class _V2StorefrontMapState extends State<V2StorefrontMap> {
  static const _styleUrl = 'https://tiles.openfreemap.org/styles/positron';

  MapLibreMapController? _mapController;
  bool _styleLoaded = false;
  bool _syncing = false;
  bool _syncAgain = false;
  String? _lastFingerprint;
  String? _errorText;

  @override
  void didUpdateWidget(covariant V2StorefrontMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_syncAnnotations());
      if (oldWidget.selectedStorefront?.id != widget.selectedStorefront?.id) {
        unawaited(_easeToSelectedStorefront());
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

      final storefrontCircles = <CircleOptions>[];
      final circleData = <Map<String, Object>>[];
      final orderedStorefronts = [
        ...widget.storefronts.where(
          (storefront) => storefront.id != widget.selectedStorefront?.id,
        ),
        ...widget.storefronts.where(
          (storefront) => storefront.id == widget.selectedStorefront?.id,
        ),
      ];

      for (final storefront in orderedStorefronts) {
        final isSelected = storefront.id == widget.selectedStorefront?.id;
        final isSubscribed = widget.isSubscribed(storefront.id);
        final isOwned = widget.canManage(storefront.id);
        final color = isOwned
            ? '#D97706'
            : isSelected
            ? '#E11D48'
            : isSubscribed
            ? '#6D28D9'
            : '#176B87';

        storefrontCircles.add(
          CircleOptions(
            geometry: storefront.location,
            circleRadius: isSelected ? 13 : 10,
            circleColor: color,
            circleOpacity: 0.98,
            circleStrokeColor: '#FFFFFF',
            circleStrokeWidth: isSelected ? 4 : 3,
            circleStrokeOpacity: 1,
          ),
        );
        circleData.add({'storefrontId': storefront.id});
      }

      if (storefrontCircles.isNotEmpty) {
        await controller.addCircles(storefrontCircles, circleData);
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
    final selectedId = widget.selectedStorefront?.id ?? 'none';
    final storefrontState = widget.storefronts
        .map(
          (storefront) =>
              '${storefront.id}:'
              '${widget.canManage(storefront.id)}:'
              '${widget.isSubscribed(storefront.id)}',
        )
        .join('|');
    return '$selectedId|$storefrontState';
  }

  Future<void> _easeToSelectedStorefront() async {
    final controller = _mapController;
    final selected = widget.selectedStorefront;
    if (!_styleLoaded || controller == null || selected == null) return;

    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(selected.location, 14.55),
    );
  }

  void _handleCircleTapped(Circle circle) {
    final storefrontId = circle.data?['storefrontId'] as String?;
    if (storefrontId == null) return;
    widget.onStorefrontSelected(storefrontId);
  }
}
