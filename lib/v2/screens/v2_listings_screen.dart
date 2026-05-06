import 'package:flutter/material.dart';

import 'package:homebased_project/v2/models/v2_marketplace.dart';
import 'package:homebased_project/v2/screens/v2_storefront_detail_screen.dart';
import 'package:homebased_project/v2/state/v2_app_controller.dart';
import 'package:homebased_project/v2/widgets/v2_marketplace_forms.dart';
import 'package:homebased_project/v2/widgets/v2_storefront_card.dart';

class V2ListingsScreen extends StatelessWidget {
  final V2AppController controller;

  const V2ListingsScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isOwner = controller.userType == V2UserType.owner;
    final storefronts = isOwner
        ? controller.ownedStorefronts
        : controller.nearbyStorefronts;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            sliver: SliverToBoxAdapter(
              child: _StorefrontsHeader(
                isOwner: isOwner,
                onCreate: () => _openCreateStorefrontSheet(context),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: storefronts.isEmpty
                ? SliverToBoxAdapter(
                    child: _EmptyPanel(
                      isOwner: isOwner,
                      onCreate: () => _openCreateStorefrontSheet(context),
                    ),
                  )
                : SliverList.separated(
                    itemCount: storefronts.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final storefront = storefronts[index];
                      return isOwner
                          ? _OwnedStorefrontPanel(
                              controller: controller,
                              storefront: storefront,
                              onOpen: () =>
                                  _openStorefront(context, storefront),
                            )
                          : V2StorefrontCard(
                              storefront: storefront,
                              distanceKm: controller.distanceFromCurrentKm(
                                storefront,
                              ),
                              catalogCount: controller
                                  .catalogFor(storefront.id)
                                  .length,
                              subscriberCount: controller.subscriberCountFor(
                                storefront.id,
                              ),
                              subscribed: controller.isSubscribed(
                                storefront.id,
                              ),
                              owned: controller.canManage(storefront.id),
                              showSubscriptionAction: true,
                              onOpen: () =>
                                  _openStorefront(context, storefront),
                              onToggleSubscription: () =>
                                  _toggleSubscription(storefront.id),
                            );
                    },
                  ),
          ),
        ],
      ),
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

  void _toggleSubscription(String storefrontId) {
    if (controller.isSubscribed(storefrontId)) {
      controller.unsubscribe(storefrontId);
    } else {
      controller.subscribe(storefrontId);
    }
  }

  void _openCreateStorefrontSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => V2StorefrontFormSheet(
        title: 'Create storefront',
        onSubmit: ({required description, required name, required pickupArea}) {
          controller.createStorefront(
            name: name,
            description: description,
            pickupArea: pickupArea,
          );
        },
      ),
    );
  }
}

class _StorefrontsHeader extends StatelessWidget {
  final bool isOwner;
  final VoidCallback onCreate;

  const _StorefrontsHeader({required this.isOwner, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOwner ? 'Manage storefronts' : 'Nearby storefronts',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF17201D),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isOwner
                        ? 'Edit your storefront, food catalog, and thread.'
                        : 'Browse food sellers inside the local radius.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF647067),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (isOwner)
              FilledButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.add),
                label: const Text('Create'),
              ),
          ],
        ),
      ],
    );
  }
}

class _OwnedStorefrontPanel extends StatelessWidget {
  final V2AppController controller;
  final V2Storefront storefront;
  final VoidCallback onOpen;

  const _OwnedStorefrontPanel({
    required this.controller,
    required this.storefront,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final catalog = controller.catalogFor(storefront.id);
    final comments = controller.commentsFor(storefront.id);
    final subscriptions = controller.subscriptionsFor(storefront.id);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            V2StorefrontCard(
              storefront: storefront,
              distanceKm: controller.distanceFromCurrentKm(storefront),
              catalogCount: catalog.length,
              subscriberCount: subscriptions.length,
              subscribed: controller.isSubscribed(storefront.id),
              owned: true,
              compact: true,
              onOpen: onOpen,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Catalog',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _openEditStorefront(context),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit store'),
                ),
                TextButton.icon(
                  onPressed: () => _openAddItem(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add item'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (catalog.isEmpty)
              const _InfoStrip(
                icon: Icons.restaurant_menu_outlined,
                label: 'No food items yet.',
              )
            else
              ...catalog
                  .take(3)
                  .map(
                    (item) => _OwnerCatalogRow(
                      item: item,
                      onEdit: () => _openEditItem(context, item),
                    ),
                  ),
            const SizedBox(height: 12),
            Text(
              'Subscribers',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            if (subscriptions.isEmpty)
              const _InfoStrip(
                icon: Icons.hourglass_empty,
                label: 'No subscribers yet.',
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: subscriptions
                    .map(
                      (subscription) => _SubscriberChip(
                        controller.displayNameFor(subscription.userId),
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Thread',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: onOpen,
                  icon: const Icon(Icons.forum_outlined),
                  label: const Text('Open'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (comments.isEmpty)
              const _InfoStrip(
                icon: Icons.forum_outlined,
                label: 'No comments yet.',
              )
            else
              ...comments.reversed
                  .take(2)
                  .map(
                    (comment) => _ThreadPreview(
                      author: controller.displayNameFor(comment.userId),
                      body: comment.body,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _openEditStorefront(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => V2StorefrontFormSheet(
        title: 'Edit storefront',
        storefront: storefront,
        onSubmit: ({required description, required name, required pickupArea}) {
          controller.updateStorefront(
            storefrontId: storefront.id,
            name: name,
            description: description,
            pickupArea: pickupArea,
          );
        },
      ),
    );
  }

  void _openAddItem(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => V2CatalogItemFormSheet(
        title: 'Add food item',
        onSubmit:
            ({
              required availability,
              required description,
              required name,
              required price,
            }) {
              controller.addCatalogItem(
                storefrontId: storefront.id,
                name: name,
                description: description,
                price: price,
                availability: availability,
              );
            },
      ),
    );
  }

  void _openEditItem(BuildContext context, V2CatalogItem item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => V2CatalogItemFormSheet(
        title: 'Edit food item',
        item: item,
        onSubmit:
            ({
              required availability,
              required description,
              required name,
              required price,
            }) {
              controller.updateCatalogItem(
                itemId: item.id,
                name: name,
                description: description,
                price: price,
                availability: availability,
              );
            },
      ),
    );
  }
}

class _OwnerCatalogRow extends StatelessWidget {
  final V2CatalogItem item;
  final VoidCallback onEdit;

  const _OwnerCatalogRow({required this.item, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFF6F7F4),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8E2)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.priceLabel} · ${item.availabilityLabel}',
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
                tooltip: 'Edit food item',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubscriberChip extends StatelessWidget {
  final String name;

  const _SubscriberChip(this.name);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F4),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2E8E2)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Text(name, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _ThreadPreview extends StatelessWidget {
  final String author;
  final String body;

  const _ThreadPreview({required this.author, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.forum_outlined, size: 18, color: Color(0xFF176B87)),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: const TextStyle(color: Color(0xFF647067), height: 1.3),
                children: [
                  TextSpan(
                    text: '$author: ',
                    style: const TextStyle(
                      color: Color(0xFF39433E),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  TextSpan(text: body),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  final bool isOwner;
  final VoidCallback onCreate;

  const _EmptyPanel({required this.isOwner, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(
              isOwner ? Icons.storefront_outlined : Icons.search_off,
              size: 34,
              color: const Color(0xFF647067),
            ),
            const SizedBox(height: 10),
            Text(
              isOwner ? 'No owned storefronts yet.' : 'No storefronts nearby.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF39433E),
                fontWeight: FontWeight.w900,
              ),
            ),
            if (isOwner) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.add),
                label: const Text('Create storefront'),
              ),
            ],
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
