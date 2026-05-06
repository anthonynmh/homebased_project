import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:homebased_project/v2/models/v2_marketplace.dart';
import 'package:homebased_project/v2/screens/v2_storefront_detail_screen.dart';
import 'package:homebased_project/v2/state/v2_app_controller.dart';
import 'package:homebased_project/v2/widgets/v2_floating_storefront_card.dart';
import 'package:homebased_project/v2/widgets/v2_storefront_map.dart';

class V2MapScreen extends StatefulWidget {
  final V2AppController controller;

  const V2MapScreen({super.key, required this.controller});

  @override
  State<V2MapScreen> createState() => _V2MapScreenState();
}

class _V2MapScreenState extends State<V2MapScreen> {
  late final PageController _pageController;
  String? _lastSyncedStorefrontId;

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
    final storefronts = widget.controller.nearbyStorefronts;
    final selected = _selectedVisibleStorefront(storefronts);
    final supportsInteractiveMap = _supportsInteractiveMap;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 620;
        final cardWidth = math.min(constraints.maxWidth, 540.0);
        final cardHeight = _cardHeightFor(constraints.maxHeight);

        return Stack(
          children: [
            Positioned.fill(
              child: supportsInteractiveMap
                  ? V2StorefrontMap(
                      currentLocation: widget.controller.currentLocation,
                      storefronts: storefronts,
                      selectedStorefront: selected,
                      isSubscribed: widget.controller.isSubscribed,
                      canManage: widget.controller.canManage,
                      onStorefrontSelected: widget.controller.selectStorefront,
                    )
                  : _MapFallbackSurface(
                      controller: widget.controller,
                      storefronts: storefronts,
                      selectedStorefront: selected,
                      onSelect: widget.controller.selectStorefront,
                      onOpen: _openStorefront,
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
                      maxWidth: isWide ? 540 : double.infinity,
                    ),
                    child: _MapTopOverlay(
                      userType: widget.controller.userType,
                      storefrontCount: storefronts.length,
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
                    child: storefronts.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: _EmptyFloatingCard(),
                          )
                        : _StorefrontCarousel(
                            controller: widget.controller,
                            pageController: _pageController,
                            storefronts: storefronts,
                            onOpen: _openStorefront,
                            onPageChanged: (index) {
                              if (index < 0 || index >= storefronts.length) {
                                return;
                              }
                              widget.controller.selectStorefront(
                                storefronts[index].id,
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
    if (screenHeight < 590) return 170;
    if (screenHeight < 720) return 184;
    return 196;
  }

  bool get _supportsInteractiveMap {
    if (kIsWeb) return true;

    return switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS => true,
      TargetPlatform.fuchsia ||
      TargetPlatform.linux ||
      TargetPlatform.macOS ||
      TargetPlatform.windows => false,
    };
  }

  V2Storefront? _selectedVisibleStorefront(List<V2Storefront> storefronts) {
    if (storefronts.isEmpty) return null;

    final selectedId = widget.controller.selectedStorefront?.id;
    for (final storefront in storefronts) {
      if (storefront.id == selectedId) return storefront;
    }

    return storefronts.first;
  }

  void _openStorefront(V2Storefront storefront) {
    widget.controller.selectStorefront(storefront.id);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => V2StorefrontDetailScreen(
          controller: widget.controller,
          storefrontId: storefront.id,
        ),
      ),
    );
  }

  void _handleControllerChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncPageToSelected();
    });
  }

  void _syncPageToSelected() {
    final storefronts = widget.controller.nearbyStorefronts;
    final selected = _selectedVisibleStorefront(storefronts);
    if (selected == null || selected.id == _lastSyncedStorefrontId) return;

    final index = storefronts.indexWhere(
      (storefront) => storefront.id == selected.id,
    );
    if (index == -1 || !_pageController.hasClients) return;

    _lastSyncedStorefrontId = selected.id;
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

class _StorefrontCarousel extends StatelessWidget {
  final V2AppController controller;
  final PageController pageController;
  final List<V2Storefront> storefronts;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<V2Storefront> onOpen;

  const _StorefrontCarousel({
    required this.controller,
    required this.pageController,
    required this.storefronts,
    required this.onPageChanged,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,
      clipBehavior: Clip.none,
      physics: const BouncingScrollPhysics(),
      itemCount: storefronts.length,
      onPageChanged: onPageChanged,
      itemBuilder: (context, index) {
        final storefront = storefronts[index];
        final subscribed = controller.isSubscribed(storefront.id);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: V2FloatingStorefrontCard(
            storefront: storefront,
            distanceKm: controller.distanceFromCurrentKm(storefront),
            catalogCount: controller.catalogFor(storefront.id).length,
            subscriberCount: controller.subscriberCountFor(storefront.id),
            subscribed: subscribed,
            owned: controller.canManage(storefront.id),
            casualMode: controller.userType == V2UserType.casual,
            onOpen: () => onOpen(storefront),
            onToggleSubscription: () {
              if (subscribed) {
                controller.unsubscribe(storefront.id);
              } else {
                controller.subscribe(storefront.id);
              }
            },
          ),
        );
      },
    );
  }
}

class _MapFallbackSurface extends StatelessWidget {
  final V2AppController controller;
  final List<V2Storefront> storefronts;
  final V2Storefront? selectedStorefront;
  final ValueChanged<String> onSelect;
  final ValueChanged<V2Storefront> onOpen;

  const _MapFallbackSurface({
    required this.controller,
    required this.storefronts,
    required this.selectedStorefront,
    required this.onSelect,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFFEAF1EF)),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 82, 16, 220),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FallbackLocationCard(),
                  const SizedBox(height: 12),
                  Expanded(
                    child: storefronts.isEmpty
                        ? const Center(child: _FallbackEmptyState())
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemCount: storefronts.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final storefront = storefronts[index];
                              final selected =
                                  storefront.id == selectedStorefront?.id;
                              return _FallbackStorefrontRow(
                                storefront: storefront,
                                distanceKm: controller.distanceFromCurrentKm(
                                  storefront,
                                ),
                                selected: selected,
                                subscribed: controller.isSubscribed(
                                  storefront.id,
                                ),
                                owned: controller.canManage(storefront.id),
                                onTap: () => onSelect(storefront.id),
                                onOpen: () => onOpen(storefront),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FallbackLocationCard extends StatelessWidget {
  const _FallbackLocationCard();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD6E1DB)),
      ),
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.my_location_outlined, color: Color(0xFF176B87)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Mock location · Singapore center',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(0xFF17201D),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FallbackStorefrontRow extends StatelessWidget {
  final V2Storefront storefront;
  final double distanceKm;
  final bool selected;
  final bool subscribed;
  final bool owned;
  final VoidCallback onTap;
  final VoidCallback onOpen;

  const _FallbackStorefrontRow({
    required this.storefront,
    required this.distanceKm,
    required this.selected,
    required this.subscribed,
    required this.owned,
    required this.onTap,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final color = owned
        ? const Color(0xFFD97706)
        : selected
        ? const Color(0xFFE11D48)
        : subscribed
        ? const Color(0xFF6D28D9)
        : const Color(0xFF176B87);

    return Material(
      color: Colors.white.withValues(alpha: selected ? 0.98 : 0.84),
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: selected ? 18 : 14,
                height: selected ? 18 : 14,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      storefront.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF17201D),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${storefront.pickupArea} · '
                      '${distanceKm.toStringAsFixed(1)} km',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF647067),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Open storefront',
                onPressed: onOpen,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FallbackEmptyState extends StatelessWidget {
  const _FallbackEmptyState();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, color: Color(0xFF647067)),
            SizedBox(width: 10),
            Text(
              'No storefronts nearby.',
              style: TextStyle(
                color: Color(0xFF39433E),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapTopOverlay extends StatelessWidget {
  final V2UserType userType;
  final int storefrontCount;
  final double radiusKm;

  const _MapTopOverlay({
    required this.userType,
    required this.storefrontCount,
    required this.radiusKm,
  });

  @override
  Widget build(BuildContext context) {
    final isOwner = userType == V2UserType.owner;

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
              icon: isOwner ? Icons.storefront : Icons.explore,
              label: userType.label,
              color: isOwner
                  ? const Color(0xFFFFF7ED)
                  : const Color(0xFFEFF6FF),
              textColor: isOwner
                  ? const Color(0xFF9A3412)
                  : const Color(0xFF1D4ED8),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$storefrontCount nearby storefronts',
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
                'No storefronts nearby. Create one from owner mode to keep exploring.',
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
