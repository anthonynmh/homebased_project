import 'package:flutter/material.dart';

import 'package:homebased_project/v2/models/v2_marketplace.dart';

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
    final theme = Theme.of(context);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: EdgeInsets.all(compact ? 14 : 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StoreLogo(storefront: storefront),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      storefront.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF17201D),
                        height: 1.08,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      storefront.description,
                      maxLines: compact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.3,
                        color: const Color(0xFF39433E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _TinyPill(
                                label: storefront.pickupArea,
                                color: const Color(0xFFFFFBEB),
                                textColor: const Color(0xFF92400E),
                              ),
                              _TinyPill(
                                label: '$catalogCount products',
                                color: const Color(0xFFEFF6FF),
                                textColor: const Color(0xFF1D4ED8),
                              ),
                              if (subscribed)
                                const _TinyPill(
                                  label: 'Subscribed',
                                  color: Color(0xFFECFDF5),
                                  textColor: Color(0xFF047857),
                                ),
                            ],
                          ),
                        ),
                        if (showSubscriptionAction && !owned) ...[
                          const SizedBox(width: 10),
                          subscribed
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
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (!showSubscriptionAction) ...[
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: 'Open storefront',
                  onPressed: onOpen,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StoreLogo extends StatelessWidget {
  final V2Storefront storefront;

  const _StoreLogo({required this.storefront});

  @override
  Widget build(BuildContext context) {
    final initial = storefront.name.trim().isEmpty
        ? '?'
        : storefront.name.trim().substring(0, 1).toUpperCase();
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1EF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD6E1DB)),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Color(0xFF176B87),
            fontWeight: FontWeight.w900,
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}

class _TinyPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _TinyPill({
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
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
