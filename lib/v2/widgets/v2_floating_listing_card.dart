import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:homebased_project/v2/models/v2_listing.dart';

class V2FloatingListingCard extends StatelessWidget {
  final V2Listing listing;
  final double distanceKm;
  final bool subscribed;
  final bool casualMode;
  final VoidCallback? onSubscribe;
  final VoidCallback? onReject;

  const V2FloatingListingCard({
    super.key,
    required this.listing,
    required this.distanceKm,
    required this.subscribed,
    required this.casualMode,
    this.onSubscribe,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = DateFormat('d MMM');
    final dateLabel =
        '${formatter.format(listing.availableFrom)}-${formatter.format(listing.availableUntil)}';

    return Material(
      color: Colors.white,
      elevation: 16,
      shadowColor: const Color(0x33000000),
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
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
                        listing.title,
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
                        '${listing.listerName} · ${listing.pickupArea}',
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
                Text(
                  listing.priceLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: const Color(0xFF176B87),
                    fontWeight: FontWeight.w900,
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
                    icon: Icons.event_available_outlined,
                    label: dateLabel,
                    color: const Color(0xFFECFDF5),
                    textColor: const Color(0xFF047857),
                  ),
                ),
                const SizedBox(width: 7),
                _MetricPill(
                  icon: Icons.people_alt_outlined,
                  label: '${listing.interestCount}',
                  color: const Color(0xFFF5F3FF),
                  textColor: const Color(0xFF6D28D9),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                _CategoryBadge(
                  label: listing.ownedByCurrentLister
                      ? 'Your listing'
                      : listing.category,
                ),
                const Spacer(),
                if (casualMode) ...[
                  IconButton.filledTonal(
                    tooltip: 'Reject listing',
                    onPressed: onReject,
                    icon: const Icon(Icons.close),
                    constraints: const BoxConstraints.tightFor(
                      width: 44,
                      height: 44,
                    ),
                  ),
                  const SizedBox(width: 9),
                  FilledButton.icon(
                    onPressed: subscribed ? null : onSubscribe,
                    icon: Icon(
                      subscribed
                          ? Icons.notifications_active
                          : Icons.notifications_none,
                      size: 18,
                    ),
                    label: Text(subscribed ? 'Subscribed' : 'Subscribe'),
                  ),
                ] else
                  FilledButton.tonalIcon(
                    onPressed: null,
                    icon: const Icon(Icons.groups_outlined, size: 18),
                    label: Text('${listing.interestCount} interested'),
                  ),
              ],
            ),
          ],
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
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF1D4ED8),
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
