import 'package:flutter/material.dart';

import 'package:homebased_project/v2/models/v2_marketplace.dart';
import 'package:homebased_project/v2/widgets/v2_ui.dart';

class V2StorefrontCard extends StatelessWidget {
  final V2Storefront storefront;
  final double distanceKm;
  final int catalogCount;
  final int subscriberCount;
  final bool subscribed;
  final bool owned;
  final bool compact;
  final bool showSubscriptionAction;
  final VoidCallback? onOpen;
  final VoidCallback? onToggleSubscription;

  const V2StorefrontCard({
    super.key,
    required this.storefront,
    required this.distanceKm,
    required this.catalogCount,
    required this.subscriberCount,
    required this.subscribed,
    required this.owned,
    this.compact = false,
    this.showSubscriptionAction = false,
    this.onOpen,
    this.onToggleSubscription,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onOpen,
        child: V2Card(
          color: Colors.white,
          padding: EdgeInsets.all(compact ? 14 : 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              V2StorefrontAvatar(
                storefront: storefront,
                size: compact ? 50 : 58,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            storefront.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: v2Ink,
                                  height: 1.08,
                                ),
                          ),
                        ),
                        if (!showSubscriptionAction) ...[
                          const SizedBox(width: 8),
                          IconButton.filledTonal(
                            tooltip: 'Open storefront',
                            onPressed: onOpen,
                            icon: const Icon(Icons.chevron_right),
                            constraints: const BoxConstraints.tightFor(
                              width: 42,
                              height: 42,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      storefront.description,
                      maxLines: compact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.3,
                        color: const Color(0xFF39433E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        V2StatusChip(
                          icon: Icons.place_outlined,
                          label:
                              '${storefront.pickupArea} · ${distanceKm.toStringAsFixed(1)} km',
                          color: const Color(0xFFFFF4E8),
                          textColor: const Color(0xFF9A4F1F),
                        ),
                        V2StatusChip(
                          icon: Icons.inventory_2_outlined,
                          label: '$catalogCount listings',
                          color: const Color(0xFFEAF3EF),
                          textColor: v2Teal,
                        ),
                        V2StatusChip(
                          icon: Icons.people_alt_outlined,
                          label: '$subscriberCount interested',
                          color: const Color(0xFFF5F3FF),
                          textColor: const Color(0xFF6D28D9),
                        ),
                        if (subscribed)
                          const V2StatusChip(
                            icon: Icons.notifications_active_outlined,
                            label: 'Subscribed',
                            color: Color(0xFFECFDF5),
                            textColor: Color(0xFF047857),
                          ),
                      ],
                    ),
                    if (showSubscriptionAction && !owned) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: subscribed
                            ? OutlinedButton.icon(
                                onPressed: onToggleSubscription,
                                icon: const Icon(
                                  Icons.notifications_off_outlined,
                                  size: 18,
                                ),
                                label: const Text('Unsubscribe'),
                              )
                            : FilledButton.icon(
                                onPressed: onToggleSubscription,
                                icon: const Icon(
                                  Icons.notifications_none,
                                  size: 18,
                                ),
                                label: const Text('Subscribe'),
                              ),
                      ),
                    ],
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

class V2CatalogItemCard extends StatelessWidget {
  final V2CatalogItem product;
  final String storefrontName;
  final bool interestCheck;
  final int signalCount;
  final int replyCount;
  final VoidCallback? onTap;
  final Widget? trailing;

  const V2CatalogItemCard({
    super.key,
    required this.product,
    required this.storefrontName,
    this.interestCheck = false,
    this.signalCount = 0,
    this.replyCount = 0,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final status = interestCheck
        ? const V2StatusChip(
            label: 'Testing demand',
            icon: Icons.lightbulb_outline,
          )
        : const V2StatusChip(
            label: 'Available now',
            icon: Icons.check_circle_outline,
            color: Color(0xFFECFDF5),
            textColor: Color(0xFF047857),
          );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: V2Card(
          color: interestCheck ? const Color(0xFFFFFCF7) : Colors.white,
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 84,
                child: V2ProductImage(
                  imageUrl: product.imageUrl,
                  icon: interestCheck
                      ? Icons.lightbulb_outline
                      : Icons.inventory_2_outlined,
                ),
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
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: v2Ink,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              height: 1.1,
                            ),
                          ),
                        ),
                        Text(
                          product.priceLabel,
                          style: const TextStyle(
                            color: v2Teal,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        status,
                        V2StatusChip(
                          label: storefrontName,
                          color: const Color(0xFFEAF3EF),
                          textColor: v2Teal,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF39433E),
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        V2StatusChip(
                          label: product.category,
                          color: const Color(0xFFFFF4E8),
                          textColor: const Color(0xFF9A4F1F),
                        ),
                        if (interestCheck) ...[
                          V2MetricChip(
                            icon: Icons.trending_up,
                            label: 'signals',
                            value: '$signalCount',
                          ),
                          V2MetricChip(
                            icon: Icons.chat_bubble_outline,
                            label: 'replies',
                            value: '$replyCount',
                          ),
                        ],
                        if (trailing != null) trailing!,
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

class V2ThreadCard extends StatelessWidget {
  final String title;
  final String storefrontName;
  final String relatedLabel;
  final String preview;
  final int replyCount;
  final VoidCallback? onOpen;

  const V2ThreadCard({
    super.key,
    required this.title,
    required this.storefrontName,
    required this.relatedLabel,
    required this.preview,
    required this.replyCount,
    this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onOpen,
        child: V2Card(
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
                child: const Icon(Icons.forum_outlined, color: v2Teal),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        V2StatusChip(
                          label: storefrontName,
                          color: const Color(0xFFFFF4E8),
                          textColor: const Color(0xFF9A4F1F),
                        ),
                        V2StatusChip(
                          label: relatedLabel,
                          color: const Color(0xFFEAF3EF),
                          textColor: v2Teal,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: v2Ink,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      preview,
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
                          value: '$replyCount',
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
