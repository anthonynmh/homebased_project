import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:homebased_project/v2/models/v2_listing.dart';
import 'package:homebased_project/v2/state/v2_app_controller.dart';
import 'package:homebased_project/v2/widgets/v2_floating_listing_card.dart';
import 'package:homebased_project/v2/widgets/v2_listing_map.dart';

class V2MapScreen extends StatefulWidget {
  final V2AppController controller;

  const V2MapScreen({super.key, required this.controller});

  @override
  State<V2MapScreen> createState() => _V2MapScreenState();
}

class _V2MapScreenState extends State<V2MapScreen> {
  late final PageController _pageController;
  String? _lastSyncedListingId;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
    widget.controller.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant V2MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerChanged);
      widget.controller.addListener(_handleControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listings = widget.controller.nearbyListings;
    final selected = _selectedVisibleListing(listings);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 620;
        final cardWidth = math.min(constraints.maxWidth, 520.0);
        final cardHeight = _cardHeightFor(constraints.maxHeight);

        return Stack(
          children: [
            Positioned.fill(
              child: V2ListingMap(
                currentLocation: widget.controller.currentLocation,
                listings: listings,
                selectedListing: selected,
                isSubscribed: widget.controller.isSubscribed,
                onListingSelected: widget.controller.selectListing,
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              top: 0,
              child: SafeArea(
                bottom: false,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isWide ? 520 : double.infinity,
                    ),
                    child: _MapTopOverlay(
                      mode: widget.controller.mode,
                      listingCount: listings.length,
                      radiusKm: widget.controller.radiusKm,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: SafeArea(
                top: false,
                minimum: const EdgeInsets.only(bottom: 4),
                child: Center(
                  child: SizedBox(
                    width: cardWidth,
                    height: cardHeight,
                    child: listings.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: _EmptyFloatingCard(),
                          )
                        : _ListingCarousel(
                            controller: widget.controller,
                            pageController: _pageController,
                            listings: listings,
                            onPageChanged: (index) {
                              if (index < 0 || index >= listings.length) {
                                return;
                              }
                              widget.controller.selectListing(
                                listings[index].id,
                              );
                            },
                          ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  double _cardHeightFor(double screenHeight) {
    if (screenHeight < 590) return 164;
    if (screenHeight < 720) return 176;
    return 188;
  }

  V2Listing? _selectedVisibleListing(List<V2Listing> listings) {
    if (listings.isEmpty) return null;

    final selectedId = widget.controller.selectedListing?.id;
    for (final listing in listings) {
      if (listing.id == selectedId) return listing;
    }

    return listings.first;
  }

  void _handleControllerChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncPageToSelected();
    });
  }

  void _syncPageToSelected() {
    final listings = widget.controller.nearbyListings;
    final selected = _selectedVisibleListing(listings);
    if (selected == null || selected.id == _lastSyncedListingId) return;

    final index = listings.indexWhere((listing) => listing.id == selected.id);
    if (index == -1 || !_pageController.hasClients) return;

    _lastSyncedListingId = selected.id;
    final currentPage =
        _pageController.page?.round() ?? _pageController.initialPage;

    if (currentPage == index) return;

    unawaited(
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      ),
    );
  }
}

class _ListingCarousel extends StatelessWidget {
  final V2AppController controller;
  final PageController pageController;
  final List<V2Listing> listings;
  final ValueChanged<int> onPageChanged;

  const _ListingCarousel({
    required this.controller,
    required this.pageController,
    required this.listings,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,
      clipBehavior: Clip.none,
      physics: const BouncingScrollPhysics(),
      itemCount: listings.length,
      onPageChanged: onPageChanged,
      itemBuilder: (context, index) {
        final listing = listings[index];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: V2FloatingListingCard(
            listing: listing,
            distanceKm: controller.distanceFromCurrentKm(listing),
            subscribed: controller.isSubscribed(listing.id),
            casualMode: controller.mode == V2UserMode.casual,
            onSubscribe: () => controller.subscribe(listing.id),
            onReject: () => controller.reject(listing.id),
          ),
        );
      },
    );
  }
}

class _MapTopOverlay extends StatelessWidget {
  final V2UserMode mode;
  final int listingCount;
  final double radiusKm;

  const _MapTopOverlay({
    required this.mode,
    required this.listingCount,
    required this.radiusKm,
  });

  @override
  Widget build(BuildContext context) {
    final isLister = mode == V2UserMode.lister;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8E2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        child: Row(
          children: [
            _CompactPill(
              icon: isLister ? Icons.storefront : Icons.explore,
              label: mode.label,
              color: isLister
                  ? const Color(0xFFFFF7ED)
                  : const Color(0xFFEFF6FF),
              textColor: isLister
                  ? const Color(0xFF9A3412)
                  : const Color(0xFF1D4ED8),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$listingCount nearby listings',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF17201D),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _CompactPill(
              icon: Icons.radio_button_checked,
              label: '${radiusKm.toStringAsFixed(0)}KM',
              color: const Color(0xFFECFDF5),
              textColor: const Color(0xFF047857),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;

  const _CompactPill({
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: textColor),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFloatingCard extends StatelessWidget {
  const _EmptyFloatingCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 14,
      shadowColor: const Color(0x33000000),
      borderRadius: BorderRadius.circular(8),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.search_off, color: Color(0xFF647067)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'No visible listings nearby. Switch modes or create a listing to keep exploring.',
                style: TextStyle(
                  color: Color(0xFF39433E),
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
