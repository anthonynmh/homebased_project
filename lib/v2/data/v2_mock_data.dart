import 'package:maplibre_gl/maplibre_gl.dart';

import 'package:homebased_project/v2/models/v2_listing.dart';

List<V2Listing> buildV2MockListings() {
  final now = DateTime.now();

  return [
    V2Listing(
      id: 'cake-001',
      title: 'Pandan chiffon cake',
      category: 'Cake',
      description:
          'Soft pandan chiffon baked in small batches if enough neighbours are interested.',
      listerName: 'Mika Bakes',
      pickupArea: 'River Valley',
      priceLabel: 'Est. S\$18',
      availableFrom: now.add(const Duration(days: 2)),
      availableUntil: now.add(const Duration(days: 7)),
      location: const LatLng(1.3002, 103.8399),
      ownedByCurrentLister: false,
      subscriptions: const [
        V2Subscription(
          id: 'sub-01',
          userName: 'Alicia',
          note: 'Interested in one whole cake.',
          status: 'Interested',
        ),
        V2Subscription(
          id: 'sub-02',
          userName: 'Ben',
          note: 'Would pick up on Friday evening.',
          status: 'Interested',
        ),
      ],
      threadMessages: const [
        V2ThreadMessage(
          author: 'Mika Bakes',
          message: 'Opening a batch if we hit 8 cakes by Thursday.',
          timeLabel: 'Today',
          fromLister: true,
        ),
      ],
    ),
    V2Listing(
      id: 'kueh-002',
      title: 'Assorted kueh box',
      category: 'Dessert',
      description:
          'A sampler with ondeh-ondeh, kueh salat, and steamed tapioca slices.',
      listerName: 'Nora Kitchen',
      pickupArea: 'Somerset',
      priceLabel: 'Est. S\$12',
      availableFrom: now.add(const Duration(days: 1)),
      availableUntil: now.add(const Duration(days: 5)),
      location: const LatLng(1.3046, 103.8328),
      ownedByCurrentLister: false,
      subscriptions: const [
        V2Subscription(
          id: 'sub-03',
          userName: 'Cheryl',
          note: 'Two boxes if coconut is not too sweet.',
          status: 'Question',
        ),
      ],
      threadMessages: const [
        V2ThreadMessage(
          author: 'Cheryl',
          message: 'Can you do less sweet?',
          timeLabel: '1h',
          fromLister: false,
        ),
        V2ThreadMessage(
          author: 'Nora Kitchen',
          message: 'Yes, I can make this batch less sweet.',
          timeLabel: '45m',
          fromLister: true,
        ),
      ],
    ),
    V2Listing(
      id: 'focaccia-003',
      title: 'Rosemary focaccia slab',
      category: 'Bread',
      description:
          'Olive oil focaccia with rosemary and flaky salt, baked when interest is confirmed.',
      listerName: 'Loaf Lab',
      pickupArea: 'Dhoby Ghaut',
      priceLabel: 'Est. S\$16',
      availableFrom: now.add(const Duration(days: 3)),
      availableUntil: now.add(const Duration(days: 6)),
      location: const LatLng(1.2962, 103.8454),
      ownedByCurrentLister: true,
      subscriptions: const [
        V2Subscription(
          id: 'sub-04',
          userName: 'Dev',
          note: 'Can collect after 6pm.',
          status: 'Interested',
        ),
        V2Subscription(
          id: 'sub-05',
          userName: 'Elaine',
          note: 'Interested if vegetarian toppings are available.',
          status: 'Question',
        ),
        V2Subscription(
          id: 'sub-06',
          userName: 'Farah',
          note: 'One slab for office snacks.',
          status: 'Interested',
        ),
      ],
      threadMessages: const [
        V2ThreadMessage(
          author: 'Loaf Lab',
          message: 'Testing demand for a Friday bake. Minimum 6 slabs.',
          timeLabel: 'Yesterday',
          fromLister: true,
        ),
        V2ThreadMessage(
          author: 'Elaine',
          message: 'Any mushroom option?',
          timeLabel: '2h',
          fromLister: false,
        ),
      ],
    ),
    V2Listing(
      id: 'puffs-004',
      title: 'Mini durian puffs',
      category: 'Pastry',
      description:
          'Chilled mini puffs with D24 filling. Listing is to confirm enough demand before buying fruit.',
      listerName: 'Cream Corner',
      pickupArea: 'Orchard',
      priceLabel: 'Est. S\$22',
      availableFrom: now.add(const Duration(days: 4)),
      availableUntil: now.add(const Duration(days: 8)),
      location: const LatLng(1.3091, 103.8458),
      ownedByCurrentLister: false,
      subscriptions: const [
        V2Subscription(
          id: 'sub-07',
          userName: 'Grace',
          note: 'One box if available on weekend.',
          status: 'Interested',
        ),
      ],
      threadMessages: const [
        V2ThreadMessage(
          author: 'Cream Corner',
          message: 'Weekend slot depends on supplier confirmation.',
          timeLabel: '3h',
          fromLister: true,
        ),
      ],
    ),
    V2Listing(
      id: 'outside-005',
      title: 'Granola refill pouch',
      category: 'Breakfast',
      description:
          'A deliberately farther listing to prove the 2KM filter is working.',
      listerName: 'Morning Jar',
      pickupArea: 'Tiong Bahru',
      priceLabel: 'Est. S\$10',
      availableFrom: now.add(const Duration(days: 2)),
      availableUntil: now.add(const Duration(days: 9)),
      location: const LatLng(1.2852, 103.8268),
      ownedByCurrentLister: true,
      subscriptions: const [],
      threadMessages: const [
        V2ThreadMessage(
          author: 'Morning Jar',
          message: 'Watching interest for next week.',
          timeLabel: 'Today',
          fromLister: true,
        ),
      ],
    ),
  ];
}
