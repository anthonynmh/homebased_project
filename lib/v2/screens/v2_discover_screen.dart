import 'package:flutter/material.dart';

import 'package:homebased_project/v2/models/v2_marketplace.dart';
import 'package:homebased_project/v2/screens/v2_storefront_detail_screen.dart';
import 'package:homebased_project/v2/state/v2_app_controller.dart';
import 'package:homebased_project/v2/widgets/v2_storefront_card.dart';

class V2DiscoverScreen extends StatefulWidget {
  final V2AppController controller;

  const V2DiscoverScreen({super.key, required this.controller});

  @override
  State<V2DiscoverScreen> createState() => _V2DiscoverScreenState();
}

class _V2DiscoverScreenState extends State<V2DiscoverScreen> {
  final _searchController = TextEditingController();
  String _category = 'All';
  bool _nearbyOnly = true;
  bool _popularOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final categories = widget.controller.storefrontCategories;
        if (!categories.contains(_category)) _category = 'All';
        final storefronts = widget.controller.discoverStorefronts(
          query: _searchController.text,
          category: _category,
          nearbyOnly: _nearbyOnly,
          popularOnly: _popularOnly,
        );

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _Header(count: storefronts.length),
              const SizedBox(height: 14),
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  labelText: 'Search stores or products',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              _Filters(
                categories: categories,
                selectedCategory: _category,
                nearbyOnly: _nearbyOnly,
                popularOnly: _popularOnly,
                onCategoryChanged: (value) => setState(() => _category = value),
                onNearbyChanged: (value) => setState(() => _nearbyOnly = value),
                onPopularChanged: (value) =>
                    setState(() => _popularOnly = value),
              ),
              const SizedBox(height: 12),
              _ExplorePanel(
                controller: widget.controller,
                storefronts: storefronts,
                onOpen: _openStorefront,
              ),
              const SizedBox(height: 16),
              Text(
                'Storefronts',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              if (storefronts.isEmpty)
                const _EmptyPanel(
                  icon: Icons.search_off,
                  label: 'No storefronts match those filters.',
                )
              else
                ...storefronts.map(
                  (storefront) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: V2StorefrontCard(
                      storefront: storefront,
                      distanceKm: widget.controller.distanceFromCurrentKm(
                        storefront,
                      ),
                      catalogCount: widget.controller
                          .catalogFor(storefront.id)
                          .length,
                      subscriberCount: widget.controller.subscriberCountFor(
                        storefront.id,
                      ),
                      subscribed: widget.controller.isSubscribed(storefront.id),
                      owned: widget.controller.canManage(storefront.id),
                      showSubscriptionAction: true,
                      onOpen: () => _openStorefront(storefront),
                      onToggleSubscription: () =>
                          _toggleSubscription(storefront.id),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
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

  void _toggleSubscription(String storefrontId) {
    if (widget.controller.isSubscribed(storefrontId)) {
      widget.controller.unsubscribe(storefrontId);
    } else {
      widget.controller.subscribe(storefrontId);
    }
  }
}

class _Header extends StatelessWidget {
  final int count;

  const _Header({required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Discover',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: const Color(0xFF17201D),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '$count storefronts around the mock neighborhood',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF647067),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _Filters extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final bool nearbyOnly;
  final bool popularOnly;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<bool> onNearbyChanged;
  final ValueChanged<bool> onPopularChanged;

  const _Filters({
    required this.categories,
    required this.selectedCategory,
    required this.nearbyOnly,
    required this.popularOnly,
    required this.onCategoryChanged,
    required this.onNearbyChanged,
    required this.onPopularChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        DropdownMenu<String>(
          initialSelection: selectedCategory,
          label: const Text('Category'),
          dropdownMenuEntries: categories
              .map(
                (category) =>
                    DropdownMenuEntry(value: category, label: category),
              )
              .toList(),
          onSelected: (value) {
            if (value != null) onCategoryChanged(value);
          },
        ),
        FilterChip(
          avatar: const Icon(Icons.near_me_outlined, size: 18),
          label: const Text('Nearby'),
          selected: nearbyOnly,
          onSelected: onNearbyChanged,
        ),
        FilterChip(
          avatar: const Icon(Icons.trending_up, size: 18),
          label: const Text('Popular'),
          selected: popularOnly,
          onSelected: onPopularChanged,
        ),
      ],
    );
  }
}

class _ExplorePanel extends StatelessWidget {
  final V2AppController controller;
  final List<V2Storefront> storefronts;
  final ValueChanged<V2Storefront> onOpen;

  const _ExplorePanel({
    required this.controller,
    required this.storefronts,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final visible = storefronts.take(4).toList();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1EF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD6E1DB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.map_outlined, color: Color(0xFF176B87)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Mock explore area',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 164,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.58),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 22,
                    top: 28,
                    child: _MapPin(label: 'You', color: Color(0xFF17201D)),
                  ),
                  for (var i = 0; i < visible.length; i++)
                    Positioned(
                      left: 78.0 + (i * 47),
                      top: 26.0 + ((i % 2) * 58),
                      child: GestureDetector(
                        onTap: () => onOpen(visible[i]),
                        child: _MapPin(
                          label: visible[i].name,
                          color: controller.isSubscribed(visible[i].id)
                              ? const Color(0xFF047857)
                              : const Color(0xFF176B87),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            if (visible.isEmpty)
              const Text(
                'No pins for the current filters.',
                style: TextStyle(
                  color: Color(0xFF647067),
                  fontWeight: FontWeight.w700,
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: visible
                    .map(
                      (storefront) => ActionChip(
                        avatar: const Icon(Icons.storefront_outlined, size: 18),
                        label: Text(storefront.name),
                        onPressed: () => onOpen(storefront),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final String label;
  final Color color;

  const _MapPin({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.location_on, color: color, size: 32),
        SizedBox(
          width: 76,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF39433E),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _EmptyPanel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF647067)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF39433E),
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
