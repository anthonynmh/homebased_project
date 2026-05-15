import 'package:flutter/material.dart';

import 'package:homebased_project/v2/models/v2_marketplace.dart';
import 'package:homebased_project/v2/screens/v2_storefront_detail_screen.dart';
import 'package:homebased_project/v2/state/v2_app_controller.dart';
import 'package:homebased_project/v2/widgets/v2_storefront_card.dart';

class V2SubscribedScreen extends StatelessWidget {
  final V2AppController controller;

  const V2SubscribedScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final storefronts = controller.subscribedStorefronts();
        final products = controller.recentSubscribedProducts();

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Text(
                'Subscribed',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF17201D),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${storefronts.length} storefronts sending you updates',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF647067),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              if (storefronts.isEmpty)
                const _EmptyPanel()
              else ...[
                _SummaryPanel(storefronts: storefronts, products: products),
                const SizedBox(height: 12),
                Text(
                  'Stores',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                ...storefronts.map(
                  (storefront) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: V2StorefrontCard(
                      storefront: storefront,
                      distanceKm: controller.distanceFromCurrentKm(storefront),
                      catalogCount: controller.catalogFor(storefront.id).length,
                      subscriberCount: controller.subscriberCountFor(
                        storefront.id,
                      ),
                      subscribed: true,
                      owned: controller.canManage(storefront.id),
                      showSubscriptionAction: true,
                      onOpen: () => _openStorefront(context, storefront),
                      onToggleSubscription: () =>
                          controller.unsubscribe(storefront.id),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Recent products',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                if (products.isEmpty)
                  const _InfoStrip(
                    icon: Icons.restaurant_menu_outlined,
                    label: 'Subscribed stores have no products yet.',
                  )
                else
                  ...products
                      .take(6)
                      .map(
                        (product) => _ProductRow(
                          product: product,
                          storeName: controller.storefrontNameFor(
                            product.storefrontId,
                          ),
                        ),
                      ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _openStorefront(BuildContext context, V2Storefront storefront) {
    controller.selectStorefront(storefront.id);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => V2StorefrontDetailScreen(
          controller: controller,
          storefrontId: storefront.id,
        ),
      ),
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  final List<V2Storefront> storefronts;
  final List<V2CatalogItem> products;

  const _SummaryPanel({required this.storefronts, required this.products});

  @override
  Widget build(BuildContext context) {
    final upcoming = products
        .where((product) => product.status == V2ProductStatus.upcoming)
        .length;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _StatTile(
              icon: Icons.storefront_outlined,
              label: 'Stores',
              value: '${storefronts.length}',
            ),
            _StatTile(
              icon: Icons.restaurant_menu_outlined,
              label: 'Products',
              value: '${products.length}',
            ),
            _StatTile(
              icon: Icons.event_outlined,
              label: 'Upcoming',
              value: '$upcoming',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 142,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFF6F7F4),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8E2)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF176B87), size: 20),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      label,
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
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final V2CatalogItem product;
  final String storeName;

  const _ProductRow({required this.product, required this.storeName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(
                Icons.restaurant_menu_outlined,
                color: Color(0xFF176B87),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      '$storeName · ${product.statusLabel}',
                      style: const TextStyle(
                        color: Color(0xFF647067),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                product.priceLabel,
                style: const TextStyle(
                  color: Color(0xFF176B87),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(Icons.notifications_none, size: 34, color: Color(0xFF647067)),
            SizedBox(height: 10),
            Text(
              'No subscriptions yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF39433E),
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Subscribe from Discover to collect store updates here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF647067),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoStrip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoStrip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF1D4ED8)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF1D4ED8),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
