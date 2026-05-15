import 'package:flutter/material.dart';

import 'package:homebased_project/v2/models/v2_marketplace.dart';
import 'package:homebased_project/v2/screens/v2_thread_detail_screen.dart';
import 'package:homebased_project/v2/state/v2_app_controller.dart';

class V2OwnerCommunityScreen extends StatelessWidget {
  final V2AppController controller;

  const V2OwnerCommunityScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final storefront = controller.ownerStorefront;
        final threads = storefront == null
            ? const <V2DiscussionThread>[]
            : controller.threadsForStorefront(storefront.id);

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Text(
                'Community',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF17201D),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                storefront == null
                    ? 'Create a storefront first.'
                    : '${threads.length} discussion threads for ${storefront.name}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF647067),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              if (storefront == null)
                const _EmptyPanel(
                  icon: Icons.storefront_outlined,
                  label: 'Switch to My Store to create a storefront first.',
                )
              else ...[
                _SummaryPanel(controller: controller, storefront: storefront),
                const SizedBox(height: 12),
                if (threads.isEmpty)
                  const _EmptyPanel(
                    icon: Icons.forum_outlined,
                    label: 'No discussion threads yet.',
                  )
                else
                  ...threads.map(
                    (thread) => _ThreadTile(
                      controller: controller,
                      thread: thread,
                      onOpen: () => _openThread(context, thread),
                    ),
                  ),
              ],
            ],
          ),
        );
      },
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

class _SummaryPanel extends StatelessWidget {
  final V2AppController controller;
  final V2Storefront storefront;

  const _SummaryPanel({required this.controller, required this.storefront});

  @override
  Widget build(BuildContext context) {
    final threads = controller.threadsForStorefront(storefront.id);
    final replies = controller.commentsFor(storefront.id);
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
              icon: Icons.forum_outlined,
              label: 'Threads',
              value: '${threads.length}',
            ),
            _StatTile(
              icon: Icons.chat_bubble_outline,
              label: 'Replies',
              value: '${replies.length}',
            ),
            _StatTile(
              icon: Icons.people_alt_outlined,
              label: 'Subscribers',
              value: '${controller.subscriberCountFor(storefront.id)}',
            ),
          ],
        ),
      ),
    );
  }
}

class _ThreadTile extends StatelessWidget {
  final V2AppController controller;
  final V2DiscussionThread thread;
  final VoidCallback onOpen;

  const _ThreadTile({
    required this.controller,
    required this.thread,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final comments = controller.commentsForThread(thread.id);
    final latest = comments.isEmpty ? null : comments.last;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFEFF6FF),
                  child: Icon(Icons.forum_outlined, color: Color(0xFF1D4ED8)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        thread.title,
                        style: const TextStyle(
                          color: Color(0xFF17201D),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        thread.relatedLabel,
                        style: const TextStyle(
                          color: Color(0xFF647067),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        latest == null
                            ? 'No replies yet.'
                            : '${controller.displayNameFor(latest.userId)}: ${latest.body}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF39433E),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    Text(
                      '${comments.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const Text(
                      'replies',
                      style: TextStyle(
                        color: Color(0xFF647067),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
  final IconData icon;
  final String label;

  const _EmptyPanel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF647067)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
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
