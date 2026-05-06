import 'package:flutter/material.dart';

import 'package:homebased_project/v2/models/v2_marketplace.dart';
import 'package:homebased_project/v2/state/v2_app_controller.dart';
import 'package:homebased_project/v2/widgets/v2_marketplace_forms.dart';

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
        final catalog = controller.catalogFor(storefront.id);
        final comments = controller.commentsFor(storefront.id);

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
                  catalogCount: catalog.length,
                  subscriberCount: controller.subscriberCountFor(storefront.id),
                ),
                const SizedBox(height: 12),
                _CatalogSection(
                  controller: controller,
                  storefront: storefront,
                  items: catalog,
                  owned: owned,
                ),
                const SizedBox(height: 12),
                _ThreadSection(
                  controller: controller,
                  storefront: storefront,
                  comments: comments,
                  canComment: controller.canComment(storefront.id),
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
  final int catalogCount;
  final int subscriberCount;

  const _StorefrontHero({
    required this.controller,
    required this.storefront,
    required this.owned,
    required this.subscribed,
    required this.catalogCount,
    required this.subscriberCount,
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
                        '${storefront.pickupArea} · '
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
                  label: '$catalogCount food items',
                  color: const Color(0xFFEFF6FF),
                  textColor: const Color(0xFF1D4ED8),
                ),
                _TinyPill(
                  icon: Icons.people_alt_outlined,
                  label: '$subscriberCount subscribers',
                  color: const Color(0xFFF5F3FF),
                  textColor: const Color(0xFF6D28D9),
                ),
                if (owned)
                  const _TinyPill(
                    icon: Icons.admin_panel_settings_outlined,
                    label: 'Owner view',
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
            const SizedBox(height: 14),
            if (owned)
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _openStorefrontEditor(context),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit storefront'),
                    ),
                  ),
                ],
              )
            else
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
        ),
      ),
    );
  }

  void _openStorefrontEditor(BuildContext context) {
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
}

class _CatalogSection extends StatelessWidget {
  final V2AppController controller;
  final V2Storefront storefront;
  final List<V2CatalogItem> items;
  final bool owned;

  const _CatalogSection({
    required this.controller,
    required this.storefront,
    required this.items,
    required this.owned,
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
                    'Food catalog',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (owned)
                  TextButton.icon(
                    onPressed: () => _openAddItem(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add item'),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (items.isEmpty)
              const _EmptyStrip(
                icon: Icons.restaurant_menu_outlined,
                label: 'No food items yet.',
              )
            else
              ...items.map(
                (item) => _CatalogItemTile(
                  item: item,
                  owned: owned,
                  onEdit: () => _openEditItem(context, item),
                ),
              ),
          ],
        ),
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

class _CatalogItemTile extends StatelessWidget {
  final V2CatalogItem item;
  final bool owned;
  final VoidCallback onEdit;

  const _CatalogItemTile({
    required this.item,
    required this.owned,
    required this.onEdit,
  });

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF17201D),
                            ),
                          ),
                        ),
                        Text(
                          item.priceLabel,
                          style: const TextStyle(
                            color: Color(0xFF176B87),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: const TextStyle(
                        color: Color(0xFF647067),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _TinyPill(
                      icon: Icons.event_available_outlined,
                      label: item.availabilityLabel,
                      color: const Color(0xFFECFDF5),
                      textColor: const Color(0xFF047857),
                    ),
                  ],
                ),
              ),
              if (owned) ...[
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: 'Edit food item',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ThreadSection extends StatelessWidget {
  final V2AppController controller;
  final V2Storefront storefront;
  final List<V2Comment> comments;
  final bool canComment;

  const _ThreadSection({
    required this.controller,
    required this.storefront,
    required this.comments,
    required this.canComment,
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
              'Storefront thread',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            if (comments.isEmpty)
              const _EmptyStrip(
                icon: Icons.forum_outlined,
                label: 'No comments yet.',
              )
            else
              ...comments.map(
                (comment) => _CommentBubble(
                  author: controller.displayNameFor(comment.userId),
                  comment: comment,
                  fromOwner: storefront.ownerId == comment.userId,
                ),
              ),
            const SizedBox(height: 8),
            if (canComment)
              _CommentComposer(controller: controller, storefront: storefront)
            else
              const _EmptyStrip(
                icon: Icons.notifications_none,
                label: 'Subscribe to join this thread.',
              ),
          ],
        ),
      ),
    );
  }
}

class _CommentComposer extends StatefulWidget {
  final V2AppController controller;
  final V2Storefront storefront;

  const _CommentComposer({required this.controller, required this.storefront});

  @override
  State<_CommentComposer> createState() => _CommentComposerState();
}

class _CommentComposerState extends State<_CommentComposer> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: _commentController,
            minLines: 1,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Comment',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        IconButton.filled(
          tooltip: 'Post comment',
          onPressed: _post,
          icon: const Icon(Icons.send),
        ),
      ],
    );
  }

  void _post() {
    final posted = widget.controller.postComment(
      storefrontId: widget.storefront.id,
      body: _commentController.text,
    );

    if (posted) {
      _commentController.clear();
      FocusScope.of(context).unfocus();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Add a comment first.')));
    }
  }
}

class _CommentBubble extends StatelessWidget {
  final String author;
  final V2Comment comment;
  final bool fromOwner;

  const _CommentBubble({
    required this.author,
    required this.comment,
    required this.fromOwner,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            fromOwner ? Icons.storefront : Icons.person_outline,
            size: 18,
            color: fromOwner
                ? const Color(0xFFD97706)
                : const Color(0xFF176B87),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$author · ${_timeLabel(comment.createdAt)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    color: Color(0xFF39433E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  comment.body,
                  style: const TextStyle(color: Color(0xFF647067), height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeLabel(DateTime createdAt) {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d';
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
