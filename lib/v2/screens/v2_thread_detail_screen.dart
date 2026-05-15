import 'package:flutter/material.dart';

import 'package:homebased_project/v2/models/v2_marketplace.dart';
import 'package:homebased_project/v2/state/v2_app_controller.dart';

class V2ThreadDetailScreen extends StatelessWidget {
  final V2AppController controller;
  final String threadId;

  const V2ThreadDetailScreen({
    super.key,
    required this.controller,
    required this.threadId,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final thread = controller.threadById(threadId);
        if (thread == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Discussion')),
            body: const Center(child: Text('Discussion not found.')),
          );
        }
        final comments = controller.commentsForThread(thread.id);
        final canReply = controller.canComment(thread.storefrontId);

        return Scaffold(
          appBar: AppBar(title: Text(thread.title)),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                DecoratedBox(
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
                          thread.title,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${controller.storefrontNameFor(thread.storefrontId)} · ${thread.relatedLabel}',
                          style: const TextStyle(
                            color: Color(0xFF647067),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DecoratedBox(
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
                          'Replies',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 12),
                        if (comments.isEmpty)
                          const _EmptyStrip(
                            icon: Icons.forum_outlined,
                            label: 'No replies yet.',
                          )
                        else
                          ...comments.map(
                            (comment) => _ReplyBubble(
                              author: controller.displayNameFor(comment.userId),
                              comment: comment,
                            ),
                          ),
                        const SizedBox(height: 10),
                        if (canReply)
                          _ReplyComposer(controller: controller, thread: thread)
                        else
                          const _EmptyStrip(
                            icon: Icons.notifications_none,
                            label: 'Subscribe to reply.',
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ReplyComposer extends StatefulWidget {
  final V2AppController controller;
  final V2DiscussionThread thread;

  const _ReplyComposer({required this.controller, required this.thread});

  @override
  State<_ReplyComposer> createState() => _ReplyComposerState();
}

class _ReplyComposerState extends State<_ReplyComposer> {
  final _replyController = TextEditingController();

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: _replyController,
            minLines: 1,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Reply',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        IconButton.filled(
          tooltip: 'Post reply',
          onPressed: _post,
          icon: const Icon(Icons.send),
        ),
      ],
    );
  }

  void _post() {
    final posted = widget.controller.postThreadReply(
      threadId: widget.thread.id,
      body: _replyController.text,
    );
    if (posted) {
      _replyController.clear();
      FocusScope.of(context).unfocus();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Add a reply first.')));
    }
  }
}

class _ReplyBubble extends StatelessWidget {
  final String author;
  final V2Comment comment;

  const _ReplyBubble({required this.author, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.person_outline, size: 18, color: Color(0xFF176B87)),
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
