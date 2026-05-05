import 'package:flutter/material.dart';

import 'package:homebased_project/v2/models/v2_listing.dart';
import 'package:homebased_project/v2/state/v2_app_controller.dart';
import 'package:homebased_project/v2/widgets/v2_listing_card.dart';
import 'package:homebased_project/v2/widgets/v2_listing_map.dart';

class V2MapScreen extends StatelessWidget {
  final V2AppController controller;

  const V2MapScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final listings = controller.nearbyListings;
    final selected = controller.selectedListing;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nearby listings',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF17201D),
                            ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${listings.length} visible within 2KM of mocked Singapore',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF647067),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                _ModeBadge(mode: controller.mode),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE2E8E2)),
                  ),
                  child: V2ListingMap(
                    currentLocation: controller.currentLocation,
                    listings: listings,
                    selectedListing: selected,
                    onListingSelected: controller.selectListing,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (selected == null)
              const _EmptySelectionPanel()
            else
              V2ListingCard(
                listing: selected,
                compact: true,
                distanceKm: controller.distanceFromCurrentKm(selected),
                subscribed: controller.isSubscribed(selected.id),
                showCasualActions: controller.mode == V2UserMode.casual,
                onSubscribe: () => controller.subscribe(selected.id),
                onReject: () => controller.reject(selected.id),
              ),
          ],
        ),
      ),
    );
  }
}

class _ModeBadge extends StatelessWidget {
  final V2UserMode mode;

  const _ModeBadge({required this.mode});

  @override
  Widget build(BuildContext context) {
    final isLister = mode == V2UserMode.lister;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isLister ? const Color(0xFFFFF7ED) : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isLister ? const Color(0xFFFED7AA) : const Color(0xFFBFDBFE),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isLister ? Icons.storefront : Icons.explore,
              size: 16,
              color: isLister
                  ? const Color(0xFF9A3412)
                  : const Color(0xFF1D4ED8),
            ),
            const SizedBox(width: 6),
            Text(
              mode.label,
              style: TextStyle(
                color: isLister
                    ? const Color(0xFF9A3412)
                    : const Color(0xFF1D4ED8),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySelectionPanel extends StatelessWidget {
  const _EmptySelectionPanel();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Padding(
        padding: EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(Icons.search_off, color: Color(0xFF647067)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'No visible listings. Switch modes or create a listing to keep exploring.',
                style: TextStyle(
                  color: Color(0xFF39433E),
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
