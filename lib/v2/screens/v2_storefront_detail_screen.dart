import 'package:flutter/material.dart';

import 'package:homebased_project/v2/models/v2_marketplace.dart';
import 'package:homebased_project/v2/screens/v2_thread_detail_screen.dart';
import 'package:homebased_project/v2/state/v2_app_controller.dart';
import 'package:homebased_project/v2/widgets/v2_storefront_card.dart';
import 'package:homebased_project/v2/widgets/v2_ui.dart';

class V2StorefrontDetailScreen extends StatelessWidget {
  final V2AppController controller;
  final String storefrontId;

  const V2StorefrontDetailScreen({
    super.key,
    required this.controller,
    required this.storefrontId,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final storefront = controller.storefrontById(storefrontId);
        if (storefront == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Storefront')),
            body: const Center(child: Text('Storefront not found.')),
          );
        }

        final owned = controller.canManage(storefront.id);
        final subscribed = controller.isSubscribed(storefront.id);
        final liveProducts = controller.productsFor(
          storefront.id,
          status: V2ProductStatus.live,
        );
        final upcomingProducts = controller.productsFor(
          storefront.id,
          status: V2ProductStatus.upcoming,
        );
        final threads = controller.threadsForStorefront(storefront.id);

        return Scaffold(
          appBar: AppBar(title: Text(storefront.name)),
          body: V2Page(
            children: [
              _StorefrontHero(
                controller: controller,
                storefront: storefront,
                owned: owned,
                subscribed: subscribed,
              ),
              const SizedBox(height: 16),
              V2SectionHeader(
                title: 'Available now',
                subtitle: 'Listings customers can act on today.',
                trailing: V2MetricChip(
                  icon: Icons.inventory_2_outlined,
                  label: 'live',
                  value: '${liveProducts.length}',
                ),
              ),
              const SizedBox(height: 10),
              if (liveProducts.isEmpty)
                const V2EmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: 'No live products yet',
                  body:
                      'This storefront has not posted anything available right now.',
                )
              else
                V2ResponsiveGrid(
                  itemCount: liveProducts.length,
                  itemBuilder: (context, index) {
                    final product = liveProducts[index];
                    return V2CatalogItemCard(
                      product: product,
                      storefrontName: storefront.name,
                    );
                  },
                ),
              const SizedBox(height: 16),
              V2SectionHeader(
                title: 'Testing demand',
                subtitle:
                    'Future products and restocks shaped by customer interest.',
                trailing: V2MetricChip(
                  icon: Icons.lightbulb_outline,
                  label: 'ideas',
                  value: '${upcomingProducts.length}',
                ),
              ),
              const SizedBox(height: 10),
              if (upcomingProducts.isEmpty)
                const V2EmptyState(
                  icon: Icons.lightbulb_outline,
                  title: 'No interest checks yet',
                  body:
                      'When this seller tests a future product, it will appear here.',
                )
              else
                V2ResponsiveGrid(
                  itemCount: upcomingProducts.length,
                  itemBuilder: (context, index) {
                    final product = upcomingProducts[index];
                    final replies = _replyCountFor(product);
                    final signals =
                        replies + controller.subscriberCountFor(storefront.id);
                    return V2CatalogItemCard(
                      product: product,
                      storefrontName: storefront.name,
                      interestCheck: true,
                      replyCount: replies,
                      signalCount: signals,
                    );
                  },
                ),
              const SizedBox(height: 16),
              V2SectionHeader(
                title: 'Community',
                subtitle:
                    'Questions, updates, and signals customers can add to.',
                trailing: V2MetricChip(
                  icon: Icons.forum_outlined,
                  label: 'threads',
                  value: '${threads.length}',
                ),
              ),
              const SizedBox(height: 10),
              if (threads.isEmpty)
                const V2EmptyState(
                  icon: Icons.forum_outlined,
                  title: 'No conversations yet',
                  body:
                      'Customer questions and storefront updates will show up here.',
                )
              else
                ...threads
                    .take(4)
                    .map(
                      (thread) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ThreadPreview(
                          controller: controller,
                          thread: thread,
                          onOpen: () => _openThread(context, thread),
                        ),
                      ),
                    ),
            ],
          ),
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

  void _openThread(BuildContext context, V2DiscussionThread thread) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            V2ThreadDetailScreen(controller: controller, threadId: thread.id),
      ),
    );
  }
}

class _StorefrontHero extends StatelessWidget {
  final V2AppController controller;
  final V2Storefront storefront;
  final bool owned;
  final bool subscribed;

  const _StorefrontHero({
    required this.controller,
    required this.storefront,
    required this.owned,
    required this.subscribed,
  });

  @override
  Widget build(BuildContext context) {
    return V2Card(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              V2StorefrontAvatar(storefront: storefront, size: 64),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      storefront.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: v2Ink,
                            fontWeight: FontWeight.w900,
                            height: 1.05,
                          ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${storefront.category} · ${storefront.pickupArea} · '
                      '${controller.distanceFromCurrentKm(storefront).toStringAsFixed(1)} km away',
                      style: const TextStyle(
                        color: v2Muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            storefront.description,
            style: const TextStyle(
              color: Color(0xFF39433E),
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              V2MetricChip(
                icon: Icons.inventory_2_outlined,
                label: 'listings',
                value: '${controller.catalogFor(storefront.id).length}',
              ),
              V2MetricChip(
                icon: Icons.people_alt_outlined,
                label: 'interested',
                value: '${controller.subscriberCountFor(storefront.id)}',
              ),
              if (owned)
                const V2StatusChip(
                  icon: Icons.admin_panel_settings_outlined,
                  label: 'Your storefront',
                )
              else if (subscribed)
                const V2StatusChip(
                  icon: Icons.notifications_active_outlined,
                  label: 'Subscribed',
                  color: Color(0xFFECFDF5),
                  textColor: Color(0xFF047857),
                ),
            ],
          ),
          if (!owned) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: subscribed
                  ? OutlinedButton.icon(
                      onPressed: () => controller.unsubscribe(storefront.id),
                      icon: const Icon(Icons.notifications_off_outlined),
                      label: const Text('Unsubscribe'),
                    )
                  : FilledButton.icon(
                      onPressed: () => controller.subscribe(storefront.id),
                      icon: const Icon(Icons.notifications_none),
                      label: const Text('Subscribe for updates'),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ThreadPreview extends StatelessWidget {
  final V2AppController controller;
  final V2DiscussionThread thread;
  final VoidCallback onOpen;

  const _ThreadPreview({
    required this.controller,
    required this.thread,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final comments = controller.commentsForThread(thread.id);
    final latest = comments.isEmpty ? null : comments.last;
    return V2ThreadCard(
      title: thread.title,
      storefrontName: controller.storefrontNameFor(thread.storefrontId),
      relatedLabel: thread.relatedLabel,
      preview: latest == null
          ? 'No replies yet. Be the first to ask or show interest.'
          : '${controller.displayNameFor(latest.userId)}: ${latest.body}',
      replyCount: comments.length,
      onOpen: onOpen,
    );
  }
}
