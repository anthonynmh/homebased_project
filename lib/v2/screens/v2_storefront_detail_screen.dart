import 'package:flutter/material.dart';

import 'package:homebased_project/v2/models/v2_marketplace.dart';
import 'package:homebased_project/v2/screens/v2_thread_detail_screen.dart';
import 'package:homebased_project/v2/state/v2_app_controller.dart';

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
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _StorefrontHero(
                  controller: controller,
                  storefront: storefront,
                  owned: owned,
                  subscribed: subscribed,
                ),
                const SizedBox(height: 12),
                _ProductSection(
                  title: 'Products',
                  emptyLabel: 'No live products yet.',
                  products: liveProducts,
                ),
                const SizedBox(height: 12),
                _ProductSection(
                  title: 'Upcoming products',
                  emptyLabel: 'No upcoming products yet.',
                  products: upcomingProducts,
                ),
                const SizedBox(height: 12),
                _DiscussionPreview(
                  controller: controller,
                  threads: threads,
                  storefront: storefront,
                ),
              ],
            ),
          ),
        );
      },
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: owned
                      ? const Color(0xFFFFF7ED)
                      : const Color(0xFFEFF6FF),
                  child: Icon(
                    Icons.storefront,
                    color: owned
                        ? const Color(0xFF9A3412)
                        : const Color(0xFF1D4ED8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        storefront.name,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${storefront.category} · ${storefront.pickupArea} · '
                        '${controller.distanceFromCurrentKm(storefront).toStringAsFixed(1)} km away',
                        style: const TextStyle(
                          color: Color(0xFF647067),
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
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _TinyPill(
                  icon: Icons.restaurant_menu_outlined,
                  label:
                      '${controller.catalogFor(storefront.id).length} products',
                  color: const Color(0xFFEFF6FF),
                  textColor: const Color(0xFF1D4ED8),
                ),
                _TinyPill(
                  icon: Icons.people_alt_outlined,
                  label:
                      '${controller.subscriberCountFor(storefront.id)} subscribers',
                  color: const Color(0xFFF5F3FF),
                  textColor: const Color(0xFF6D28D9),
                ),
                if (owned)
                  const _TinyPill(
                    icon: Icons.admin_panel_settings_outlined,
                    label: 'Your storefront',
                    color: Color(0xFFFFF7ED),
                    textColor: Color(0xFF9A3412),
                  )
                else if (subscribed)
                  const _TinyPill(
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
                        label: const Text('Subscribe'),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProductSection extends StatelessWidget {
  final String title;
  final String emptyLabel;
  final List<V2CatalogItem> products;

  const _ProductSection({
    required this.title,
    required this.emptyLabel,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            if (products.isEmpty)
              _EmptyStrip(
                icon: Icons.restaurant_menu_outlined,
                label: emptyLabel,
              )
            else
              ...products.map((product) => _ProductTile(product: product)),
          ],
        ),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final V2CatalogItem product;

  const _ProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFF6F7F4),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8E2)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProductThumb(imageUrl: product.imageUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF17201D),
                            ),
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
                    const SizedBox(height: 4),
                    Text(
                      product.description,
                      style: const TextStyle(
                        color: Color(0xFF647067),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _TinyPill(
                          icon: Icons.category_outlined,
                          label: product.category,
                          color: const Color(0xFFFFFBEB),
                          textColor: const Color(0xFF92400E),
                        ),
                        _TinyPill(
                          icon: Icons.event_available_outlined,
                          label: product.statusLabel,
                          color: const Color(0xFFECFDF5),
                          textColor: const Color(0xFF047857),
                        ),
                      ],
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

class _ProductThumb extends StatelessWidget {
  final String? imageUrl;

  const _ProductThumb({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url != null && url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          url,
          width: 58,
          height: 58,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const _PlaceholderThumb(),
        ),
      );
    }
    return const _PlaceholderThumb();
  }
}

class _PlaceholderThumb extends StatelessWidget {
  const _PlaceholderThumb();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.restaurant_menu, color: Color(0xFF1D4ED8)),
    );
  }
}

class _DiscussionPreview extends StatelessWidget {
  final V2AppController controller;
  final V2Storefront storefront;
  final List<V2DiscussionThread> threads;

  const _DiscussionPreview({
    required this.controller,
    required this.storefront,
    required this.threads,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Discussions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (threads.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => _openThread(context, threads.first),
                    icon: const Icon(Icons.forum_outlined),
                    label: const Text('View all'),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (threads.isEmpty)
              const _EmptyStrip(
                icon: Icons.forum_outlined,
                label: 'No discussions yet.',
              )
            else
              ...threads
                  .take(3)
                  .map(
                    (thread) => _ThreadRow(
                      controller: controller,
                      thread: thread,
                      onTap: () => _openThread(context, thread),
                    ),
                  ),
          ],
        ),
      ),
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

class _ThreadRow extends StatelessWidget {
  final V2AppController controller;
  final V2DiscussionThread thread;
  final VoidCallback onTap;

  const _ThreadRow({
    required this.controller,
    required this.thread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final comments = controller.commentsForThread(thread.id);
    final latest = comments.isEmpty ? null : comments.last;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: const Color(0xFFF6F7F4),
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.forum_outlined, color: Color(0xFF176B87)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        thread.title,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        latest == null
                            ? thread.relatedLabel
                            : '${controller.displayNameFor(latest.userId)}: ${latest.body}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF647067),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${comments.length}',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyStrip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _EmptyStrip({required this.icon, required this.label});

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

class _TinyPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;

  const _TinyPill({
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
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
