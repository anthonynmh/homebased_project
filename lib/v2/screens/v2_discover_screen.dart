import 'package:flutter/material.dart';

import 'package:homebased_project/v2/models/v2_marketplace.dart';
import 'package:homebased_project/v2/screens/v2_storefront_detail_screen.dart';
import 'package:homebased_project/v2/state/v2_app_controller.dart';
import 'package:homebased_project/v2/widgets/v2_storefront_card.dart';
import 'package:homebased_project/v2/widgets/v2_ui.dart';

class V2DiscoverScreen extends StatefulWidget {
  final V2AppController controller;

  const V2DiscoverScreen({super.key, required this.controller});

  @override
  State<V2DiscoverScreen> createState() => _V2DiscoverScreenState();
}

class _V2DiscoverScreenState extends State<V2DiscoverScreen> {
  final _searchController = TextEditingController();
  String _category = 'All';
  bool _nearbyOnly = false;
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
        final storefronts = widget.controller.discoverStorefronts(
          query: _searchController.text,
          category: _category,
          nearbyOnly: _nearbyOnly,
          popularOnly: _popularOnly,
        );

        return V2Page(
          children: [
            V2PageHeader(
              title: 'Discover',
              subtitle:
                  'Find storefronts, follow what is available, and help shape what sellers make next.',
              action: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  V2MetricChip(
                    icon: Icons.storefront_outlined,
                    label: 'storefronts',
                    value: '${storefronts.length}',
                  ),
                  V2MetricChip(
                    icon: Icons.radio_button_checked,
                    label: 'radius',
                    value:
                        '${widget.controller.radiusKm.toStringAsFixed(0)} km',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                labelText: 'Search storefronts, products, or categories',
                border: const OutlineInputBorder(),
                suffixIcon: _searchController.text.trim().isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.close),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            _DiscoverFilters(
              categories: widget.controller.storefrontCategories,
              selectedCategory: _category,
              nearbyOnly: _nearbyOnly,
              popularOnly: _popularOnly,
              onCategorySelected: (category) {
                setState(() => _category = category);
              },
              onNearbyChanged: (value) {
                setState(() {
                  _nearbyOnly = value;
                  if (value) _popularOnly = false;
                });
              },
              onPopularChanged: (value) {
                setState(() {
                  _popularOnly = value;
                  if (value) _nearbyOnly = false;
                });
              },
            ),
            const SizedBox(height: 18),
            V2SectionHeader(
              title: _popularOnly ? 'Popular storefronts' : 'Storefronts',
              subtitle:
                  'Browse live listings, upcoming ideas, and customer updates.',
            ),
            const SizedBox(height: 10),
            if (storefronts.isEmpty)
              V2EmptyState(
                icon: Icons.search_off,
                title: 'No storefronts found',
                body:
                    'Try another search or clear filters to see more local sellers.',
                action: OutlinedButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.tune_outlined),
                  label: const Text('Clear filters'),
                ),
              )
            else
              V2ResponsiveGrid(
                itemCount: storefronts.length,
                itemBuilder: (context, index) {
                  final storefront = storefronts[index];
                  return V2StorefrontCard(
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
                  );
                },
              ),
          ],
        );
      },
    );
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _category = 'All';
      _nearbyOnly = false;
      _popularOnly = false;
    });
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

class _DiscoverFilters extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final bool nearbyOnly;
  final bool popularOnly;
  final ValueChanged<String> onCategorySelected;
  final ValueChanged<bool> onNearbyChanged;
  final ValueChanged<bool> onPopularChanged;

  const _DiscoverFilters({
    required this.categories,
    required this.selectedCategory,
    required this.nearbyOnly,
    required this.popularOnly,
    required this.onCategorySelected,
    required this.onNearbyChanged,
    required this.onPopularChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
            avatar: const Icon(Icons.place_outlined, size: 18),
            label: const Text('Nearby'),
            selected: nearbyOnly,
            onSelected: onNearbyChanged,
          ),
          const SizedBox(width: 8),
          FilterChip(
            avatar: const Icon(Icons.trending_up, size: 18),
            label: const Text('Popular'),
            selected: popularOnly,
            onSelected: onPopularChanged,
          ),
          const SizedBox(width: 8),
          ...categories.map(
            (category) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(category),
                selected: selectedCategory == category,
                onSelected: (_) => onCategorySelected(category),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
