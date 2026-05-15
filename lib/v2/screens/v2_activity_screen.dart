import 'package:flutter/material.dart';

import 'package:homebased_project/v2/models/v2_marketplace.dart';
import 'package:homebased_project/v2/state/v2_app_controller.dart';

class V2ActivityScreen extends StatelessWidget {
  final V2AppController controller;

  const V2ActivityScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final notifications = controller.notifications;

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
                          'Activity',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF17201D),
                              ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${controller.unreadNotificationCount} unread updates',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: const Color(0xFF647067),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: notifications.isEmpty
                        ? null
                        : controller.markAllNotificationsRead,
                    icon: const Icon(Icons.done_all),
                    label: const Text('Mark all read'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (notifications.isEmpty)
                const _EmptyPanel()
              else
                ...notifications.map(
                  (notification) => _NotificationTile(
                    notification: notification,
                    storeName: controller.storefrontNameFor(
                      notification.storefrontId,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final V2NotificationItem notification;
  final String storeName;

  const _NotificationTile({
    required this.notification,
    required this.storeName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: notification.read
              ? null
              : Border.all(color: const Color(0xFF176B87), width: 1.2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: _color.withValues(alpha: 0.13),
                child: Icon(_icon, color: _color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: const TextStyle(
                              color: Color(0xFF17201D),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (!notification.read)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF176B87),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$storeName · ${_timeLabel(notification.createdAt)}',
                      style: const TextStyle(
                        color: Color(0xFF647067),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.body,
                      style: const TextStyle(
                        color: Color(0xFF39433E),
                        height: 1.3,
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

  IconData get _icon => switch (notification.type) {
    'new_product' => Icons.restaurant_menu_outlined,
    'upcoming_product' => Icons.event_outlined,
    'discussion_reply' => Icons.forum_outlined,
    _ => Icons.storefront_outlined,
  };

  Color get _color => switch (notification.type) {
    'new_product' => const Color(0xFF1D4ED8),
    'upcoming_product' => const Color(0xFFD97706),
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
        child: Row(
          children: [
            Icon(Icons.notifications_none, color: Color(0xFF647067)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'No activity yet.',
                style: TextStyle(
                  color: Color(0xFF39433E),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
