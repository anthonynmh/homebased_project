import 'package:flutter/material.dart';

import 'package:homebased_project/v2/models/v2_marketplace.dart';
import 'package:homebased_project/v2/state/v2_app_controller.dart';
import 'package:homebased_project/v2/widgets/v2_ui.dart';

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
          body: V2Page(
            children: [
              V2Card(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        V2StatusChip(
                          label: controller.storefrontNameFor(
                            thread.storefrontId,
                          ),
                          color: const Color(0xFFFFF4E8),
                          textColor: const Color(0xFF9A4F1F),
                        ),
                        V2StatusChip(
                          label: thread.relatedLabel,
                          color: const Color(0xFFEAF3EF),
                          textColor: v2Teal,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      thread.title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: v2Ink, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Replies help this storefront understand what customers want next.',
                      style: TextStyle(
                        color: v2Muted,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    V2MetricChip(
                      icon: Icons.chat_bubble_outline,
                      label: 'customer replies',
                      value: '${comments.length}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const V2SectionHeader(
                title: 'Replies',
                subtitle: 'Customer questions, intent, and seller updates.',
              ),
              const SizedBox(height: 10),
              if (comments.isEmpty)
                const V2EmptyState(
                  icon: Icons.forum_outlined,
                  title: 'No replies yet',
                  body: 'Start the conversation with a question or update.',
                )
              else
                ...comments.map(
                  (comment) => _ReplyBubble(
                    author: controller.displayNameFor(comment.userId),
                    comment: comment,
                  ),
                ),
              const SizedBox(height: 4),
              if (canReply)
                V2Card(
                  color: Colors.white,
                  child: _ReplyComposer(controller: controller, thread: thread),
                )
              else
                const V2EmptyState(
                  icon: Icons.notifications_none,
                  title: 'Subscribe to reply',
                  body:
                      'Follow this storefront to ask questions and show interest.',
                ),
            ],
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
              labelText: 'Reply with a question or interest signal',
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
      padding: const EdgeInsets.only(bottom: 10),
      child: V2Card(
        color: Colors.white,
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFEAF3EF),
              child: Icon(Icons.person_outline, size: 19, color: v2Teal),
            ),
            const SizedBox(width: 10),
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
                  const SizedBox(height: 3),
                  Text(
                    comment.body,
                    style: const TextStyle(
                      color: v2Muted,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
