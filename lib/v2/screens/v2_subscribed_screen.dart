import 'package:flutter/material.dart';

import 'package:homebased_project/v2/models/v2_marketplace.dart';
import 'package:homebased_project/v2/screens/v2_storefront_detail_screen.dart';
import 'package:homebased_project/v2/state/v2_app_controller.dart';
import 'package:homebased_project/v2/widgets/v2_storefront_card.dart';
import 'package:homebased_project/v2/widgets/v2_ui.dart';

class V2SubscribedScreen extends StatelessWidget {
  final V2AppController controller;
  final VoidCallback onExplore;

  const V2SubscribedScreen({
    super.key,
    required this.controller,
    required this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final storefronts = controller.subscribedStorefronts();
        final products = controller.recentSubscribedProducts();
        final upcoming = products
            .where((product) => product.status == V2ProductStatus.upcoming)
            .length;

        return V2Page(
          children: [
            V2PageHeader(
              title: 'Subscribed',
              subtitle:
                  'Follow storefronts, catch new listings, and see what makers are testing next.',
              action: storefronts.isEmpty
                  ? null
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        V2MetricChip(
                          icon: Icons.storefront_outlined,
                          label: 'following',
                          value: '${storefronts.length}',
                        ),
                        V2MetricChip(
                          icon: Icons.inventory_2_outlined,
                          label: 'listings',
                          value: '${products.length}',
                        ),
                        V2MetricChip(
                          icon: Icons.lightbulb_outline,
                          label: 'testing',
                          value: '$upcoming',
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            if (storefronts.isEmpty)
              V2EmptyState(
                icon: Icons.notifications_none,
                title: 'No subscriptions yet',
                body:
                    'Subscribe to storefronts you care about to collect updates, new products, and interest checks here.',
                action: FilledButton.icon(
                  onPressed: onExplore,
                  icon: const Icon(Icons.explore_outlined),
                  label: const Text('Explore storefronts'),
                ),
              )
            else ...[
              V2SectionHeader(
                title: 'Storefronts you follow',
                subtitle: 'Open a storefront or pause updates anytime.',
                trailing: TextButton.icon(
                  onPressed: onExplore,
                  icon: const Icon(Icons.explore_outlined, size: 18),
                  label: const Text('Explore'),
                ),
              ),
              const SizedBox(height: 10),
              V2ResponsiveGrid(
                itemCount: storefronts.length,
                itemBuilder: (context, index) {
                  final storefront = storefronts[index];
                  return V2StorefrontCard(
                    storefront: storefront,
                    distanceKm: controller.distanceFromCurrentKm(storefront),
                    catalogCount: controller.catalogFor(storefront.id).length,
                    subscriberCount: controller.subscriberCountFor(
                      storefront.id,
                    ),
                    subscribed: true,
                    owned: controller.canManage(storefront.id),
                    compact: true,
                    showSubscriptionAction: true,
                    onOpen: () => _openStorefront(context, storefront),
                    onToggleSubscription: () =>
                        controller.unsubscribe(storefront.id),
                  );
                },
              ),
              const SizedBox(height: 18),
              const V2SectionHeader(
                title: 'Recent from followed storefronts',
                subtitle:
                    'Live products and interest checks from sellers you support.',
              ),
              const SizedBox(height: 10),
              if (products.isEmpty)
                const V2EmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: 'No listings yet',
                  body:
                      'Followed storefronts have not posted products or interest checks yet.',
                )
              else
                V2ResponsiveGrid(
                  itemCount: products.take(6).length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final replies = _replyCountFor(product);
                    final subscribers = controller.subscriberCountFor(
                      product.storefrontId,
                    );
                    final interestCheck =
                        product.status == V2ProductStatus.upcoming;
                    return V2CatalogItemCard(
                      product: product,
                      storefrontName: controller.storefrontNameFor(
                        product.storefrontId,
                      ),
                      interestCheck: interestCheck,
                      signalCount: replies + subscribers,
                      replyCount: replies,
                    );
                  },
                ),
            ],
          ],
        );
      },
    );
  }

  int _replyCountFor(V2CatalogItem product) {
    final threads = controller
        .threadsForStorefront(product.storefrontId)
        .where((thread) => thread.relatedLabel == product.name);
    return threads.fold<int>(
      0,
      (total, thread) => total + controller.commentsForThread(thread.id).length,
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
