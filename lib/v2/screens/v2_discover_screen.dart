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
        final storefronts = _filteredStorefronts();

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
                  labelText: 'Search storefront name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Storefront locations',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              if (storefronts.isEmpty)
                const _EmptyPanel(
                  icon: Icons.search_off,
                  label: 'No storefronts match that name.',
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

  List<V2Storefront> _filteredStorefronts() {
    final query = _searchController.text.trim().toLowerCase();
    final storefronts = widget.controller.allStorefronts.where((storefront) {
      if (query.isEmpty) return true;
      return storefront.name.toLowerCase().contains(query);
    }).toList();
    storefronts.sort((a, b) => a.name.compareTo(b.name));
    return storefronts;
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
          '$count storefronts listed by pickup location',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF647067),
            fontWeight: FontWeight.w600,
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
