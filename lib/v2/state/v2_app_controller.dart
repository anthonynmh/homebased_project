import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'package:homebased_project/v2/data/v2_mock_data.dart';
import 'package:homebased_project/v2/models/v2_listing.dart';
import 'package:homebased_project/v2/utils/v2_geo.dart';

class V2AppController extends ChangeNotifier {
  final List<V2Listing> _listings = buildV2MockListings();
  final Set<String> _subscribedListingIds = {};
  final Set<String> _rejectedListingIds = {};

  V2UserMode _mode = V2UserMode.casual;
  String? _selectedListingId = 'cake-001';
  int _createdListings = 0;

  V2UserMode get mode => _mode;
  LatLng get currentLocation => V2Geo.singaporeCenter;
  double get radiusKm => V2Geo.radiusKm;

  List<V2Listing> get allListings => List.unmodifiable(_listings);

  List<V2Listing> get nearbyListings {
    final listings = _listings
        .where((listing) => distanceFromCurrentKm(listing) <= radiusKm)
        .where(
          (listing) =>
              _mode == V2UserMode.lister ||
              !_rejectedListingIds.contains(listing.id),
        )
        .toList();

    listings.sort(
      (a, b) => distanceFromCurrentKm(a).compareTo(distanceFromCurrentKm(b)),
    );

    return listings;
  }

  List<V2Listing> get ownedListings {
    return _listings
        .where((listing) => listing.ownedByCurrentLister)
        .toList(growable: false);
  }

  V2Listing? get selectedListing {
    if (_selectedListingId == null) return _firstNearbyOrNull();

    for (final listing in _listings) {
      if (listing.id == _selectedListingId) return listing;
    }

    return _firstNearbyOrNull();
  }

  int get subscribedCount => _subscribedListingIds.length;
  int get rejectedCount => _rejectedListingIds.length;

  bool isSubscribed(String listingId) =>
      _subscribedListingIds.contains(listingId);

  bool isRejected(String listingId) => _rejectedListingIds.contains(listingId);

  double distanceFromCurrentKm(V2Listing listing) {
    return V2Geo.distanceKm(currentLocation, listing.location);
  }

  void setMode(V2UserMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }

  void selectListing(String listingId) {
    _selectedListingId = listingId;
    notifyListeners();
  }

  void subscribe(String listingId) {
    _subscribedListingIds.add(listingId);
    _rejectedListingIds.remove(listingId);

    final index = _listings.indexWhere((listing) => listing.id == listingId);
    if (index == -1) return;

    final listing = _listings[index];
    final alreadyInThread = listing.subscriptions.any(
      (subscription) => subscription.id == 'sub-you',
    );

    if (!alreadyInThread) {
      _listings[index] = listing.copyWith(
        subscriptions: [
          ...listing.subscriptions,
          const V2Subscription(
            id: 'sub-you',
            userName: 'You',
            note: 'Subscribed from the v2 prototype.',
            status: 'Interested',
          ),
        ],
        threadMessages: [
          ...listing.threadMessages,
          const V2ThreadMessage(
            author: 'You',
            message: 'I am interested. Please keep me updated.',
            timeLabel: 'Now',
            fromLister: false,
          ),
        ],
      );
    }

    _selectedListingId = listingId;
    notifyListeners();
  }

  void reject(String listingId) {
    _rejectedListingIds.add(listingId);
    _subscribedListingIds.remove(listingId);

    if (_selectedListingId == listingId) {
      _selectedListingId = _firstNearbyOrNull()?.id;
    }

    notifyListeners();
  }

  void createListing({
    required String title,
    required String category,
    required String description,
    required String priceLabel,
    required int availableWithinDays,
  }) {
    _createdListings += 1;
    final location = V2Geo.offsetFromCenter(
      northMeters: 180 + (_createdListings * 90),
      eastMeters: -160 + (_createdListings * 110),
    );
    final now = DateTime.now();
    final listing = V2Listing(
      id: 'created-$_createdListings',
      title: title.trim(),
      category: category.trim().isEmpty ? 'Home bake' : category.trim(),
      description: description.trim(),
      listerName: 'Your test kitchen',
      pickupArea: 'Near you',
      priceLabel: priceLabel.trim().isEmpty ? 'Price TBD' : priceLabel.trim(),
      availableFrom: now.add(const Duration(days: 1)),
      availableUntil: now.add(Duration(days: availableWithinDays)),
      location: location,
      ownedByCurrentLister: true,
      subscriptions: const [],
      threadMessages: const [
        V2ThreadMessage(
          author: 'Your test kitchen',
          message: 'New interest-check listing created.',
          timeLabel: 'Now',
          fromLister: true,
        ),
      ],
    );

    _listings.insert(0, listing);
    _selectedListingId = listing.id;
    _mode = V2UserMode.lister;
    notifyListeners();
  }

  void postOwnerUpdate(String listingId) {
    final index = _listings.indexWhere((listing) => listing.id == listingId);
    if (index == -1) return;

    final listing = _listings[index];
    _listings[index] = listing.copyWith(
      threadMessages: [
        ...listing.threadMessages,
        const V2ThreadMessage(
          author: 'Your test kitchen',
          message: 'Thanks for the interest. I will confirm the batch soon.',
          timeLabel: 'Now',
          fromLister: true,
        ),
      ],
    );

    notifyListeners();
  }

  V2Listing? _firstNearbyOrNull() {
    final listings = nearbyListings;
    return listings.isEmpty ? null : listings.first;
  }
}
