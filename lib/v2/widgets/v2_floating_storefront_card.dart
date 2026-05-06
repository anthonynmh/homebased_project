import 'package:flutter/material.dart';

import 'package:homebased_project/v2/models/v2_marketplace.dart';

class V2FloatingStorefrontCard extends StatelessWidget {
  final V2Storefront storefront;
  final double distanceKm;
  final int catalogCount;
  final int subscriberCount;
  final bool subscribed;
  final bool owned;
  final bool casualMode;
  final VoidCallback? onOpen;
  final VoidCallback? onToggleSubscription;

  const V2FloatingStorefrontCard({
    super.key,
    required this.storefront,
    required this.distanceKm,
    required this.catalogCount,
    required this.subscriberCount,
    required this.subscribed,
    required this.owned,
    required this.casualMode,
    this.onOpen,
    this.onToggleSubscription,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.white,
      elevation: 16,
      shadowColor: const Color(0x33000000),
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          storefront.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF17201D),
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          storefront.pickupArea,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF647067),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
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
              ),
              const SizedBox(height: 11),
              Row(
                children: [
                  _MetricPill(
                    icon: Icons.place_outlined,
                    label: '${distanceKm.toStringAsFixed(1)} km',
                    color: const Color(0xFFFFFBEB),
                    textColor: const Color(0xFF92400E),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: _MetricPill(
                      icon: Icons.restaurant_menu_outlined,
                      label: '$catalogCount food items',
                      color: const Color(0xFFEFF6FF),
                      textColor: const Color(0xFF1D4ED8),
                    ),
                  ),
                  const SizedBox(width: 7),
                  _MetricPill(
                    icon: Icons.people_alt_outlined,
                    label: '$subscriberCount',
                    color: const Color(0xFFF5F3FF),
                    textColor: const Color(0xFF6D28D9),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  _CategoryBadge(label: owned ? 'Your storefront' : 'Food'),
                  const Spacer(),
                  if (casualMode && !owned)
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
                          )
                  else
                    FilledButton.tonalIcon(
                      onPressed: null,
                      icon: const Icon(Icons.storefront_outlined, size: 18),
                      label: Text(owned ? 'Manage' : 'Open'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;

  const _MetricPill({
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
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: textColor, size: 14),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
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

class _CategoryBadge extends StatelessWidget {
  final String label;

  const _CategoryBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF047857),
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
