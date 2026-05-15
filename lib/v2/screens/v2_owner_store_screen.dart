import 'package:flutter/material.dart';

import 'package:homebased_project/v2/models/v2_marketplace.dart';
import 'package:homebased_project/v2/screens/v2_storefront_detail_screen.dart';
import 'package:homebased_project/v2/state/v2_app_controller.dart';
import 'package:homebased_project/v2/widgets/v2_marketplace_forms.dart';
import 'package:homebased_project/v2/widgets/v2_ui.dart';
import 'package:homebased_project/v2/widgets/v2_storefront_card.dart';

class V2OwnerStoreScreen extends StatelessWidget {
  final V2AppController controller;

  const V2OwnerStoreScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final storefronts = controller.ownedStorefronts;

        return V2Page(
          children: [
            V2PageHeader(
              title: 'My Stores',
              subtitle:
                  'Manage your storefronts, listings, and customer updates.',
              action: FilledButton.icon(
                onPressed: () => _openCreateStorefront(context),
                icon: const Icon(Icons.add_business_outlined),
                label: Text(
                  storefronts.isEmpty
                      ? 'Create storefront'
                      : 'Add another storefront',
                ),
              ),
              menu: _StoreMenu(
                storefront: storefronts.isEmpty ? null : storefronts.first,
                onCreate: () => _openCreateStorefront(context),
                onEdit: storefronts.isEmpty
                    ? null
                    : () => _openEditStorefront(context, storefronts.first),
                onPreview: storefronts.isEmpty
                    ? null
                    : () => _openDetail(context, storefronts.first),
                onDelete: storefronts.isEmpty
                    ? null
                    : () =>
                          _confirmDeleteStorefront(context, storefronts.first),
              ),
            ),
            const SizedBox(height: 16),
            if (storefronts.isEmpty)
              V2EmptyState(
                icon: Icons.storefront_outlined,
                title: 'Create your first storefront',
                body:
                    'Tell shoppers what you offer and start building product interest.',
                action: FilledButton.icon(
                  onPressed: () => _openCreateStorefront(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Create storefront'),
                ),
              )
            else ...[
              _PortfolioSummary(
                controller: controller,
                storefronts: storefronts,
              ),
              const SizedBox(height: 16),
              const V2SectionHeader(
                title: 'Storefronts',
                subtitle:
                    'Choose a storefront to manage details and preview it.',
              ),
              const SizedBox(height: 10),
              ...storefronts.map(
                (storefront) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _StorefrontManagementCard(
                    controller: controller,
                    storefront: storefront,
                    onEdit: () => _openEditStorefront(context, storefront),
                    onPreview: () => _openDetail(context, storefront),
                    onDelete: () =>
                        _confirmDeleteStorefront(context, storefront),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              _SetupGuide(
                storefront: storefronts.first,
                controller: controller,
              ),
              const SizedBox(height: 16),
              V2SectionHeader(
                title: 'Public preview',
                subtitle: 'How customers see this storefront.',
                trailing: TextButton.icon(
                  onPressed: () => _openDetail(context, storefronts.first),
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('Preview'),
                ),
              ),
              const SizedBox(height: 10),
              V2StorefrontCard(
                storefront: storefronts.first,
                distanceKm: controller.distanceFromCurrentKm(storefronts.first),
                catalogCount: controller
                    .catalogFor(storefronts.first.id)
                    .length,
                subscriberCount: controller.subscriberCountFor(
                  storefronts.first.id,
                ),
                subscribed: controller.isSubscribed(storefronts.first.id),
                owned: false,
                onOpen: () => _openDetail(context, storefronts.first),
              ),
            ],
          ],
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

  Future<void> _confirmDeleteStorefront(
    BuildContext context,
    V2Storefront storefront,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete storefront?'),
        content: Text(
          'Delete ${storefront.name}, its products, subscriptions, and '
          'discussion replies from local prototype state? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB42318),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      controller.deleteStorefront(storefront.id);
    }
  }
}

class _PortfolioSummary extends StatelessWidget {
  final V2AppController controller;
  final List<V2Storefront> storefronts;

  const _PortfolioSummary({
    required this.controller,
    required this.storefronts,
  });

  @override
  Widget build(BuildContext context) {
    final productCount = storefronts.fold<int>(
      0,
      (total, storefront) =>
          total + controller.catalogFor(storefront.id).length,
    );
    final subscriberCount = storefronts.fold<int>(
      0,
      (total, storefront) =>
          total + controller.subscriberCountFor(storefront.id),
    );
    final threadCount = storefronts.fold<int>(
      0,
      (total, storefront) =>
          total + controller.threadsForStorefront(storefront.id).length,
    );

    return V2Card(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Business hub',
            style: TextStyle(
              color: v2Ink,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Track what is live, what customers are asking about, and where to act next.',
            style: TextStyle(
              color: v2Muted,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              V2MetricChip(
                icon: Icons.storefront_outlined,
                label: 'storefronts',
                value: '${storefronts.length}',
              ),
              V2MetricChip(
                icon: Icons.inventory_2_outlined,
                label: 'listings',
                value: '$productCount',
              ),
              V2MetricChip(
                icon: Icons.people_alt_outlined,
                label: 'subscribers',
                value: '$subscriberCount',
              ),
              V2MetricChip(
                icon: Icons.forum_outlined,
                label: 'threads',
                value: '$threadCount',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StorefrontManagementCard extends StatelessWidget {
  final V2AppController controller;
  final V2Storefront storefront;
  final VoidCallback onEdit;
  final VoidCallback onPreview;
  final VoidCallback onDelete;

  const _StorefrontManagementCard({
    required this.controller,
    required this.storefront,
    required this.onEdit,
    required this.onPreview,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final liveProducts = controller.productsFor(
      storefront.id,
      status: V2ProductStatus.live,
    );
    final upcomingProducts = controller.productsFor(
      storefront.id,
      status: V2ProductStatus.upcoming,
    );
    final threads = controller.threadsForStorefront(storefront.id);

    return V2Card(
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            storefront.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: v2Ink,
                                  fontWeight: FontWeight.w900,
                                  height: 1.05,
                                ),
                          ),
                        ),
                        const V2StatusChip(
                          label: 'Taking orders',
                          icon: Icons.check_circle_outline,
                          color: Color(0xFFECFDF5),
                          textColor: Color(0xFF047857),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${storefront.category} · ${storefront.pickupArea}',
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
                label: 'live',
                value: '${liveProducts.length}',
              ),
              V2MetricChip(
                icon: Icons.lightbulb_outline,
                label: 'testing',
                value: '${upcomingProducts.length}',
              ),
              V2MetricChip(
                icon: Icons.people_alt_outlined,
                label: 'subscribers',
                value: '${controller.subscriberCountFor(storefront.id)}',
              ),
              V2MetricChip(
                icon: Icons.chat_bubble_outline,
                label: 'threads',
                value: '${threads.length}',
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.tune_outlined, size: 18),
                label: const Text('Manage'),
              ),
              OutlinedButton.icon(
                onPressed: onPreview,
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: const Text('Preview'),
              ),
              IconButton(
                tooltip: 'Delete storefront',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                color: const Color(0xFFB42318),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SetupGuide extends StatelessWidget {
  final V2Storefront storefront;
  final V2AppController controller;

  const _SetupGuide({required this.storefront, required this.controller});

  @override
  Widget build(BuildContext context) {
    final hasLiveProduct = controller
        .productsFor(storefront.id, status: V2ProductStatus.live)
        .isNotEmpty;
    final hasTest = controller
        .productsFor(storefront.id, status: V2ProductStatus.upcoming)
        .isNotEmpty;
    final hasThread = controller.threadsForStorefront(storefront.id).isNotEmpty;

    return V2Card(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const V2SectionHeader(
            title: 'Storefront setup',
            subtitle: 'A simple guide for turning a page into a business hub.',
          ),
          const SizedBox(height: 12),
          _ChecklistRow(
            complete: storefront.description.trim().isNotEmpty,
            label: 'Add profile details',
          ),
          _ChecklistRow(
            complete: hasLiveProduct,
            label: 'Add first live product or service',
          ),
          const _ChecklistRow(
            complete: false,
            label: 'Set pickup, delivery, or fulfillment details',
          ),
          _ChecklistRow(
            complete: hasTest,
            label: 'Test demand before committing supply',
          ),
          _ChecklistRow(complete: hasThread, label: 'Post a customer update'),
          const _ChecklistRow(
            complete: false,
            label: 'Share storefront with customers',
          ),
        ],
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  final bool complete;
  final String label;

  const _ChecklistRow({required this.complete, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Icon(
            complete ? Icons.check_circle : Icons.radio_button_unchecked,
            color: complete ? const Color(0xFF047857) : v2Muted,
            size: 19,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: complete ? v2Ink : v2Muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreMenu extends StatelessWidget {
  final V2Storefront? storefront;
  final VoidCallback onCreate;
  final VoidCallback? onEdit;
  final VoidCallback? onPreview;
  final VoidCallback? onDelete;

  const _StoreMenu({
    required this.storefront,
    required this.onCreate,
    required this.onEdit,
    required this.onPreview,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_StoreAction>(
      tooltip: 'Storefront actions',
      icon: const Icon(Icons.more_vert),
      onSelected: (action) {
        switch (action) {
          case _StoreAction.create:
            onCreate();
          case _StoreAction.edit:
            onEdit?.call();
          case _StoreAction.preview:
            onPreview?.call();
          case _StoreAction.delete:
            onDelete?.call();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _StoreAction.create,
          child: ListTile(
            leading: const Icon(Icons.add_business_outlined),
            title: Text(
              storefront == null ? 'Create storefront' : 'Add storefront',
            ),
          ),
        ),
        if (storefront != null) ...[
          const PopupMenuItem(
            value: _StoreAction.edit,
            child: ListTile(
              leading: Icon(Icons.edit_outlined),
              title: Text('Edit storefront'),
            ),
          ),
          const PopupMenuItem(
            value: _StoreAction.preview,
            child: ListTile(
              leading: Icon(Icons.visibility_outlined),
              title: Text('Public preview'),
            ),
          ),
          const PopupMenuItem(
            value: _StoreAction.delete,
            child: ListTile(
              leading: Icon(Icons.delete_outline, color: Color(0xFFB42318)),
              title: Text('Delete storefront'),
            ),
          ),
        ],
      ],
    );
  }
}

enum _StoreAction { create, edit, preview, delete }
