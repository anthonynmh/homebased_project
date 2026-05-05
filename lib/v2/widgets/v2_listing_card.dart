import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:homebased_project/v2/models/v2_listing.dart';

class V2ListingCard extends StatelessWidget {
  final V2Listing listing;
  final double distanceKm;
  final bool compact;
  final bool subscribed;
  final bool showCasualActions;
  final VoidCallback? onSubscribe;
  final VoidCallback? onReject;
  final VoidCallback? onSelect;

  const V2ListingCard({
    super.key,
    required this.listing,
    required this.distanceKm,
    this.compact = false,
    this.subscribed = false,
    this.showCasualActions = false,
    this.onSubscribe,
    this.onReject,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = DateFormat('d MMM');

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onSelect,
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
                                listing.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF17201D),
                                ),
                              ),
                            ),
                            if (listing.ownedByCurrentLister) ...[
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
                          '${listing.listerName} · ${listing.pickupArea}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF647067),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    listing.priceLabel,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: const Color(0xFF176B87),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              if (!compact) ...[
                const SizedBox(height: 10),
                Text(
                  listing.description,
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
                    label: listing.category,
                    color: const Color(0xFFEFF6FF),
                    textColor: const Color(0xFF1D4ED8),
                  ),
                  _TinyPill(
                    label:
                        '${formatter.format(listing.availableFrom)} to '
                        '${formatter.format(listing.availableUntil)}',
                    color: const Color(0xFFECFDF5),
                    textColor: const Color(0xFF047857),
                  ),
                  _TinyPill(
                    label: '${distanceKm.toStringAsFixed(1)} km away',
                    color: const Color(0xFFFFFBEB),
                    textColor: const Color(0xFF92400E),
                  ),
                  _TinyPill(
                    label: '${listing.interestCount} interested',
                    color: const Color(0xFFF5F3FF),
                    textColor: const Color(0xFF6D28D9),
                  ),
                ],
              ),
              if (showCasualActions) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: subscribed ? null : onSubscribe,
                        icon: Icon(
                          subscribed
                              ? Icons.notifications_active
                              : Icons.notifications_none,
                        ),
                        label: Text(subscribed ? 'Subscribed' : 'Subscribe'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton.filledTonal(
                      tooltip: 'Reject listing',
                      onPressed: onReject,
                      icon: const Icon(Icons.close),
                    ),
                  ],
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
