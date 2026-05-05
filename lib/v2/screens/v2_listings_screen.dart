import 'package:flutter/material.dart';

import 'package:homebased_project/v2/models/v2_listing.dart';
import 'package:homebased_project/v2/state/v2_app_controller.dart';
import 'package:homebased_project/v2/widgets/v2_listing_card.dart';

class V2ListingsScreen extends StatelessWidget {
  final V2AppController controller;

  const V2ListingsScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isLister = controller.mode == V2UserMode.lister;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            sliver: SliverToBoxAdapter(
              child: _ListingsHeader(
                isLister: isLister,
                onCreate: () => _openCreateSheet(context),
              ),
            ),
          ),
          if (isLister)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: SliverList.separated(
                itemCount: controller.ownedListings.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final listing = controller.ownedListings[index];
                  return _OwnedListingPanel(
                    listing: listing,
                    distanceKm: controller.distanceFromCurrentKm(listing),
                    onSelect: () => controller.selectListing(listing.id),
                    onPostUpdate: () => controller.postOwnerUpdate(listing.id),
                  );
                },
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: SliverList.separated(
                itemCount: controller.nearbyListings.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final listing = controller.nearbyListings[index];
                  return V2ListingCard(
                    listing: listing,
                    distanceKm: controller.distanceFromCurrentKm(listing),
                    subscribed: controller.isSubscribed(listing.id),
                    showCasualActions: true,
                    onSelect: () => controller.selectListing(listing.id),
                    onSubscribe: () => controller.subscribe(listing.id),
                    onReject: () => controller.reject(listing.id),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _openCreateSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _CreateListingSheet(controller: controller),
    );
  }
}

class _ListingsHeader extends StatelessWidget {
  final bool isLister;
  final VoidCallback onCreate;

  const _ListingsHeader({required this.isLister, required this.onCreate});

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
                    isLister ? 'Manage demand' : 'Interest checks',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF17201D),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isLister
                        ? 'Track subscribers and keep the thread warm.'
                        : 'Subscribe to products you may want soon.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF647067),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (isLister)
              FilledButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.add),
                label: const Text('Create'),
              ),
          ],
        ),
        if (isLister) ...[
          const SizedBox(height: 14),
          const _InfoStrip(
            icon: Icons.groups_outlined,
            label:
                'Subscriptions are local prototype data. Use them to preview the management flow.',
          ),
        ],
      ],
    );
  }
}

class _OwnedListingPanel extends StatelessWidget {
  final V2Listing listing;
  final double distanceKm;
  final VoidCallback onSelect;
  final VoidCallback onPostUpdate;

  const _OwnedListingPanel({
    required this.listing,
    required this.distanceKm,
    required this.onSelect,
    required this.onPostUpdate,
  });

  @override
  Widget build(BuildContext context) {
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
            V2ListingCard(
              listing: listing,
              distanceKm: distanceKm,
              compact: true,
              onSelect: onSelect,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Subscribers',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: onPostUpdate,
                  icon: const Icon(Icons.campaign_outlined),
                  label: const Text('Post update'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (listing.subscriptions.isEmpty)
              const _InfoStrip(
                icon: Icons.hourglass_empty,
                label:
                    'No subscribers yet. This listing is ready to collect interest.',
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: listing.subscriptions
                    .map((subscription) => _SubscriberChip(subscription))
                    .toList(),
              ),
            const SizedBox(height: 14),
            Text(
              'Community thread',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            ...listing.threadMessages.take(3).map(_ThreadBubble.new),
          ],
        ),
      ),
    );
  }
}

class _SubscriberChip extends StatelessWidget {
  final V2Subscription subscription;

  const _SubscriberChip(this.subscription);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8E2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 220),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                subscription.userName,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 3),
              Text(
                subscription.status,
                style: const TextStyle(
                  color: Color(0xFF176B87),
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subscription.note,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF647067)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThreadBubble extends StatelessWidget {
  final V2ThreadMessage message;

  const _ThreadBubble(this.message);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            message.fromLister ? Icons.storefront : Icons.person_outline,
            size: 18,
            color: message.fromLister
                ? const Color(0xFFD97706)
                : const Color(0xFF176B87),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${message.author} · ${message.timeLabel}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    color: Color(0xFF39433E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message.message,
                  style: const TextStyle(color: Color(0xFF647067), height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateListingSheet extends StatefulWidget {
  final V2AppController controller;

  const _CreateListingSheet({required this.controller});

  @override
  State<_CreateListingSheet> createState() => _CreateListingSheetState();
}

class _CreateListingSheetState extends State<_CreateListingSheet> {
  final _titleController = TextEditingController(text: 'Brown butter cookies');
  final _categoryController = TextEditingController(text: 'Cookies');
  final _descriptionController = TextEditingController(
    text: 'Testing interest before buying ingredients for a weekend bake.',
  );
  final _priceController = TextEditingController(text: 'Est. S\$14');
  int _availableWithinDays = 7;

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        top: 18,
        bottom: MediaQuery.of(context).viewInsets.bottom + 18,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Create listing',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Listing name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              minLines: 3,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Interest-check note',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Expected price',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _availableWithinDays,
                    decoration: const InputDecoration(
                      labelText: 'Available by',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 3, child: Text('3 days')),
                      DropdownMenuItem(value: 5, child: Text('5 days')),
                      DropdownMenuItem(value: 7, child: Text('7 days')),
                      DropdownMenuItem(value: 10, child: Text('10 days')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _availableWithinDays = value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.add_location_alt_outlined),
                label: const Text('Create local listing'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a listing name first.')),
      );
      return;
    }

    widget.controller.createListing(
      title: _titleController.text,
      category: _categoryController.text,
      description: _descriptionController.text,
      priceLabel: _priceController.text,
      availableWithinDays: _availableWithinDays,
    );
    Navigator.of(context).pop();
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
