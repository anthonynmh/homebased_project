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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                storefront.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF17201D),
                                ),
                              ),
                            ),
                            if (owned) ...[
                              const SizedBox(width: 8),
                              const _TinyPill(
                                label: 'Yours',
                                color: Color(0xFFFFF7ED),
                                textColor: Color(0xFF9A3412),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          storefront.pickupArea,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF647067),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filledTonal(
                    tooltip: 'Open storefront',
                    onPressed: onOpen,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
              if (!compact) ...[
                const SizedBox(height: 10),
                Text(
                  storefront.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.35,
                    color: const Color(0xFF39433E),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _TinyPill(
                    label: '$catalogCount food items',
                    color: const Color(0xFFEFF6FF),
                    textColor: const Color(0xFF1D4ED8),
                  ),
                  _TinyPill(
                    label: '${distanceKm.toStringAsFixed(1)} km away',
                    color: const Color(0xFFFFFBEB),
                    textColor: const Color(0xFF92400E),
                  ),
                  _TinyPill(
                    label: '$subscriberCount subscribers',
                    color: const Color(0xFFF5F3FF),
                    textColor: const Color(0xFF6D28D9),
                  ),
                  if (subscribed)
                    const _TinyPill(
                      label: 'Subscribed',
                      color: Color(0xFFECFDF5),
                      textColor: Color(0xFF047857),
                    ),
                ],
              ),
              if (showSubscriptionAction && !owned) ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: subscribed
                      ? OutlinedButton.icon(
                          onPressed: onToggleSubscription,
                          icon: const Icon(Icons.notifications_off_outlined),
                          label: const Text('Unsubscribe'),
                        )
                      : FilledButton.icon(
                          onPressed: onToggleSubscription,
                          icon: const Icon(Icons.notifications_none),
                          label: const Text('Subscribe'),
                        ),
                ),
              ],
            ],
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
