import 'package:flutter/material.dart';

import 'package:homebased_project/v2/models/v2_marketplace.dart';
import 'package:homebased_project/v2/state/v2_app_controller.dart';
import 'package:homebased_project/v2/widgets/v2_ui.dart';

class V2ActivityScreen extends StatelessWidget {
  final V2AppController controller;
  final VoidCallback onExplore;

  const V2ActivityScreen({
    super.key,
    required this.controller,
    required this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final notifications = controller.notifications;
        final unread = controller.unreadNotificationCount;

        return V2Page(
          children: [
            V2PageHeader(
              title: 'Activity',
              subtitle:
                  'Product updates, replies, and demand signals from storefronts you follow.',
              action: Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  V2MetricChip(
                    icon: Icons.notifications_none,
                    label: 'unread',
                    value: '$unread',
                  ),
                  TextButton.icon(
                    onPressed: notifications.isEmpty
                        ? null
                        : controller.markAllNotificationsRead,
                    icon: const Icon(Icons.done_all, size: 18),
                    label: const Text('Mark all read'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (notifications.isEmpty)
              V2EmptyState(
                icon: Icons.notifications_none,
                title: 'No activity yet',
                body:
                    'Subscribe to storefronts to see product drops, replies, and upcoming ideas here.',
                action: FilledButton.icon(
                  onPressed: onExplore,
                  icon: const Icon(Icons.explore_outlined),
                  label: const Text('Explore storefronts'),
                ),
              )
            else
              ...notifications.map(
                (notification) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _NotificationCard(
                    notification: notification,
                    storeName: controller.storefrontNameFor(
                      notification.storefrontId,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final V2NotificationItem notification;
  final String storeName;

  const _NotificationCard({
    required this.notification,
    required this.storeName,
  });

  @override
  Widget build(BuildContext context) {
    return V2Card(
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 23,
            backgroundColor: _color.withValues(alpha: 0.13),
            child: Icon(_icon, color: _color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: v2Ink,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    if (!notification.read)
                      const V2StatusChip(
                        label: 'New',
                        color: Color(0xFFFFF4E8),
                        textColor: Color(0xFF9A4F1F),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  '$storeName · ${_timeLabel(notification.createdAt)}',
                  style: const TextStyle(
                    color: v2Muted,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  notification.body,
                  style: const TextStyle(
                    color: Color(0xFF39433E),
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData get _icon => switch (notification.type) {
    'new_product' => Icons.inventory_2_outlined,
    'upcoming_product' => Icons.lightbulb_outline,
    'discussion_reply' => Icons.forum_outlined,
    _ => Icons.storefront_outlined,
  };

  Color get _color => switch (notification.type) {
    'new_product' => v2Teal,
    'upcoming_product' => v2Warm,
    'discussion_reply' => const Color(0xFF6D28D9),
    _ => const Color(0xFF047857),
  };

  String _timeLabel(DateTime createdAt) {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d';
  }
}
