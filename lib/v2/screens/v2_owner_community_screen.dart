import 'package:flutter/material.dart';

import 'package:homebased_project/v2/models/v2_marketplace.dart';
import 'package:homebased_project/v2/screens/v2_thread_detail_screen.dart';
import 'package:homebased_project/v2/state/v2_app_controller.dart';
import 'package:homebased_project/v2/widgets/v2_owner_widgets.dart';

class V2OwnerCommunityScreen extends StatefulWidget {
  final V2AppController controller;

  const V2OwnerCommunityScreen({super.key, required this.controller});

  @override
  State<V2OwnerCommunityScreen> createState() => _V2OwnerCommunityScreenState();
}

class _V2OwnerCommunityScreenState extends State<V2OwnerCommunityScreen> {
  String? _selectedStorefrontId;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final storefronts = widget.controller.ownedStorefronts;
        if (_selectedStorefrontId != null &&
            !storefronts.any(
              (storefront) => storefront.id == _selectedStorefrontId,
            )) {
          _selectedStorefrontId = null;
        }
        final selectedStorefront = _selectedStorefrontId == null
            ? null
            : widget.controller.storefrontById(_selectedStorefrontId!);
        final visibleStorefronts = selectedStorefront == null
            ? storefronts
            : [selectedStorefront];
        final threads = visibleStorefronts
            .expand(
              (storefront) =>
                  widget.controller.threadsForStorefront(storefront.id),
            )
            .toList(growable: false);

        return V2OwnerPage(
          children: [
            V2OwnerHeader(
              title: 'Community',
              subtitle:
                  'Post updates, answer customer questions, and turn replies into product decisions.',
              action: storefronts.isEmpty
                  ? null
                  : FilledButton.icon(
                      onPressed: () => _openThreadForm(
                        context,
                        selectedStorefront ?? storefronts.first,
                      ),
                      icon: const Icon(Icons.add_comment_outlined),
                      label: const Text('Post update'),
                    ),
            ),
            const SizedBox(height: 16),
            if (storefronts.isEmpty)
              const V2OwnerEmptyState(
                icon: Icons.storefront_outlined,
                title: 'Create a storefront first',
                body:
                    'Start with a storefront, then invite customers into product updates and questions.',
              )
            else ...[
              V2StorefrontSelector(
                storefronts: storefronts,
                selectedStorefrontId: _selectedStorefrontId,
                onSelected: (storefrontId) {
                  setState(() => _selectedStorefrontId = storefrontId);
                },
              ),
              const SizedBox(height: 16),
              _CommunitySummary(
                controller: widget.controller,
                storefronts: visibleStorefronts,
              ),
              const SizedBox(height: 16),
              V2OwnerSectionHeader(
                title: 'Customer conversations',
                subtitle:
                    'Use replies and questions as demand signals, not just chatter.',
                trailing: TextButton.icon(
                  onPressed: () => _openThreadForm(
                    context,
                    selectedStorefront ?? storefronts.first,
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Start thread'),
                ),
              ),
              const SizedBox(height: 10),
              if (threads.isEmpty)
                V2OwnerEmptyState(
                  icon: Icons.forum_outlined,
                  title: 'Start a conversation',
                  body:
                      'Post updates, answer questions, or test ideas with your customers.',
                  action: FilledButton.icon(
                    onPressed: () => _openThreadForm(
                      context,
                      selectedStorefront ?? storefronts.first,
                    ),
                    icon: const Icon(Icons.add_comment_outlined),
                    label: const Text('Post update'),
                  ),
                )
              else
                ...threads.map(
                  (thread) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ThreadCard(
                      controller: widget.controller,
                      thread: thread,
                      onOpen: () => _openThread(context, thread),
                    ),
                  ),
                ),
            ],
          ],
        );
      },
    );
  }

  void _openThread(BuildContext context, V2DiscussionThread thread) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => V2ThreadDetailScreen(
          controller: widget.controller,
          threadId: thread.id,
        ),
      ),
    );
  }

  void _openThreadForm(BuildContext context, V2Storefront storefront) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _ThreadFormSheet(
        storefront: storefront,
        onSubmit:
            ({required title, required relatedLabel, required openingMessage}) {
              widget.controller.createThread(
                storefrontId: storefront.id,
                title: title,
                relatedLabel: relatedLabel,
                openingMessage: openingMessage,
              );
            },
      ),
    );
  }
}

class _CommunitySummary extends StatelessWidget {
  final V2AppController controller;
  final List<V2Storefront> storefronts;

  const _CommunitySummary({
    required this.controller,
    required this.storefronts,
  });

  @override
  Widget build(BuildContext context) {
    final threads = storefronts.fold<int>(
      0,
      (total, storefront) =>
          total + controller.threadsForStorefront(storefront.id).length,
    );
    final replies = storefronts.fold<int>(
      0,
      (total, storefront) =>
          total + controller.commentsFor(storefront.id).length,
    );
    final subscribers = storefronts.fold<int>(
      0,
      (total, storefront) =>
          total + controller.subscriberCountFor(storefront.id),
    );

    return V2OwnerCard(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const V2OwnerSectionHeader(
            title: 'Demand signals',
            subtitle:
                'Compact signals from customers who subscribe, ask, or reply.',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              V2MetricChip(
                icon: Icons.forum_outlined,
                label: 'threads',
                value: '$threads',
              ),
              V2MetricChip(
                icon: Icons.chat_bubble_outline,
                label: 'replies',
                value: '$replies',
              ),
              V2MetricChip(
                icon: Icons.people_alt_outlined,
                label: 'subscribers',
                value: '$subscribers',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThreadCard extends StatelessWidget {
  final V2AppController controller;
  final V2DiscussionThread thread;
  final VoidCallback onOpen;

  const _ThreadCard({
    required this.controller,
    required this.thread,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final comments = controller.commentsForThread(thread.id);
    final latest = comments.isEmpty ? null : comments.last;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onOpen,
        child: V2OwnerCard(
          color: Colors.white,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3EF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.forum_outlined, color: v2OwnerTeal),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
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
                          textColor: v2OwnerTeal,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      thread.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: v2OwnerInk,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      latest == null
                          ? 'No replies yet. Ask a question or share an update.'
                          : '${controller.displayNameFor(latest.userId)}: ${latest.body}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF39433E),
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        V2MetricChip(
                          icon: Icons.chat_bubble_outline,
                          label: 'replies',
                          value: '${comments.length}',
                        ),
                        const Spacer(),
                        IconButton.filledTonal(
                          tooltip: 'Open thread',
                          onPressed: onOpen,
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
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

typedef _ThreadFormSubmit =
    void Function({
      required String title,
      required String relatedLabel,
      required String openingMessage,
    });

class _ThreadFormSheet extends StatefulWidget {
  final V2Storefront storefront;
  final _ThreadFormSubmit onSubmit;

  const _ThreadFormSheet({required this.storefront, required this.onSubmit});

  @override
  State<_ThreadFormSheet> createState() => _ThreadFormSheetState();
}

class _ThreadFormSheetState extends State<_ThreadFormSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _relatedController;
  late final TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: 'New customer update');
    _relatedController = TextEditingController(text: widget.storefront.name);
    _messageController = TextEditingController(
      text: 'What would you like customers to know or weigh in on?',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _relatedController.dispose();
    _messageController.dispose();
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
                    'Post update',
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
            const SizedBox(height: 6),
            Text(
              widget.storefront.name,
              style: const TextStyle(
                color: v2OwnerMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Thread title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _relatedController,
              decoration: const InputDecoration(
                labelText: 'Related product, idea, or update',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _messageController,
              minLines: 3,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Opening message',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.send_outlined),
                label: const Text('Post update'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty ||
        _messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a title and opening message.')),
      );
      return;
    }

    widget.onSubmit(
      title: _titleController.text,
      relatedLabel: _relatedController.text,
      openingMessage: _messageController.text,
    );
    Navigator.of(context).pop();
  }
}
