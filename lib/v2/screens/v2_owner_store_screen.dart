import 'package:flutter/material.dart';

import 'package:homebased_project/v2/models/v2_marketplace.dart';
import 'package:homebased_project/v2/screens/v2_storefront_detail_screen.dart';
import 'package:homebased_project/v2/state/v2_app_controller.dart';
import 'package:homebased_project/v2/widgets/v2_marketplace_forms.dart';
import 'package:homebased_project/v2/widgets/v2_storefront_card.dart';

class V2OwnerStoreScreen extends StatelessWidget {
  final V2AppController controller;

  const V2OwnerStoreScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final storefront = controller.ownerStorefront;

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Store',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF17201D),
                              ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          storefront == null
                              ? 'Create a local storefront.'
                              : '${storefront.name} · ${storefront.category}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: const Color(0xFF647067),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (storefront == null)
                    FilledButton.icon(
                      onPressed: () => _openCreateStorefront(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Create'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (storefront == null)
                const _EmptyPanel()
              else ...[
                _StoreProfilePanel(
                  controller: controller,
                  storefront: storefront,
                  onEdit: () => _openEditStorefront(context, storefront),
                ),
                const SizedBox(height: 12),
                _StatsPanel(controller: controller, storefront: storefront),
                const SizedBox(height: 12),
                Text(
                  'Casual preview',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                V2StorefrontCard(
                  storefront: storefront,
                  distanceKm: controller.distanceFromCurrentKm(storefront),
                  catalogCount: controller.catalogFor(storefront.id).length,
                  subscriberCount: controller.subscriberCountFor(storefront.id),
                  subscribed: controller.isSubscribed(storefront.id),
                  owned: true,
                  onOpen: () => _openDetail(context, storefront),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _openCreateStorefront(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => V2StorefrontFormSheet(
        title: 'Create storefront',
        onSubmit:
            ({
              required category,
              required description,
              required name,
              required pickupArea,
            }) {
              controller.createStorefront(
                name: name,
                description: description,
                category: category,
                pickupArea: pickupArea,
              );
            },
      ),
    );
  }

  void _openEditStorefront(BuildContext context, V2Storefront storefront) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => V2StorefrontFormSheet(
        title: 'Edit storefront',
        storefront: storefront,
        onSubmit:
            ({
              required category,
              required description,
              required name,
              required pickupArea,
            }) {
              controller.updateStorefront(
                storefrontId: storefront.id,
                name: name,
                description: description,
                category: category,
                pickupArea: pickupArea,
              );
            },
      ),
    );
  }

  void _openDetail(BuildContext context, V2Storefront storefront) {
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

class _StoreProfilePanel extends StatelessWidget {
  final V2AppController controller;
  final V2Storefront storefront;
  final VoidCallback onEdit;

  const _StoreProfilePanel({
    required this.controller,
    required this.storefront,
    required this.onEdit,
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
                CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFFFFF7ED),
                  child: const Icon(Icons.storefront, color: Color(0xFF9A3412)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        storefront.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '${storefront.category} · ${storefront.pickupArea}',
                        style: const TextStyle(
                          color: Color(0xFF647067),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: 'Edit storefront',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
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
          ],
        ),
      ),
    );
  }
}

class _StatsPanel extends StatelessWidget {
  final V2AppController controller;
  final V2Storefront storefront;

  const _StatsPanel({required this.controller, required this.storefront});

  @override
  Widget build(BuildContext context) {
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
              icon: Icons.restaurant_menu_outlined,
              label: 'Products',
              value:
                  '${controller.productsFor(storefront.id, status: V2ProductStatus.live).length}',
            ),
            _StatTile(
              icon: Icons.event_outlined,
              label: 'Upcoming',
              value:
                  '${controller.productsFor(storefront.id, status: V2ProductStatus.upcoming).length}',
            ),
            _StatTile(
              icon: Icons.people_alt_outlined,
              label: 'Subscribers',
              value: '${controller.subscriberCountFor(storefront.id)}',
            ),
            _StatTile(
              icon: Icons.forum_outlined,
              label: 'Threads',
              value: '${controller.threadsForStorefront(storefront.id).length}',
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
      width: 148,
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
            Icon(Icons.storefront_outlined, size: 34, color: Color(0xFF647067)),
            SizedBox(height: 10),
            Text(
              'No owner storefront yet.',
              style: TextStyle(
                color: Color(0xFF39433E),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
