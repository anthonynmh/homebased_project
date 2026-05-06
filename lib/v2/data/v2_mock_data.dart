import 'package:maplibre_gl/maplibre_gl.dart';

import 'package:homebased_project/v2/models/v2_marketplace.dart';

const v2DemoUserId = 'user-you';

Map<String, String> buildV2MockUserNames() {
  return {
    v2DemoUserId: 'Demo user',
    'user-mika': 'Mika',
    'user-nora': 'Nora',
    'user-loaf': 'Loaf Lab',
    'user-cream': 'Cream Corner',
    'user-morning': 'Morning Jar',
    'user-alicia': 'Alicia',
    'user-ben': 'Ben',
    'user-cheryl': 'Cheryl',
    'user-dev': 'Dev',
    'user-elaine': 'Elaine',
    'user-farah': 'Farah',
    'user-grace': 'Grace',
  };
}

List<V2Storefront> buildV2MockStorefronts() {
  return [
    const V2Storefront(
      id: 'sf-mika-bakes',
      ownerId: 'user-mika',
      name: 'Mika Bakes',
      description:
          'Small-batch pandan cakes, cookies, and celebration bakes from a home kitchen.',
      pickupArea: 'River Valley',
      location: LatLng(1.3002, 103.8399),
    ),
    const V2Storefront(
      id: 'sf-nora-kitchen',
      ownerId: 'user-nora',
      name: 'Nora Kitchen',
      description:
          'Traditional kueh boxes and coconut desserts prepared for nearby pickups.',
      pickupArea: 'Somerset',
      location: LatLng(1.3046, 103.8328),
    ),
    const V2Storefront(
      id: 'sf-loaf-lab',
      ownerId: v2DemoUserId,
      name: 'Loaf Lab',
      description:
          'Your mock storefront for breads and savoury bakes. Owner controls are local only.',
      pickupArea: 'Dhoby Ghaut',
      location: LatLng(1.2962, 103.8454),
    ),
    const V2Storefront(
      id: 'sf-cream-corner',
      ownerId: 'user-cream',
      name: 'Cream Corner',
      description:
          'Chilled pastries and filled puffs released in limited weekend batches.',
      pickupArea: 'Orchard',
      location: LatLng(1.3091, 103.8458),
    ),
    const V2Storefront(
      id: 'sf-morning-jar',
      ownerId: 'user-morning',
      name: 'Morning Jar',
      description:
          'Granola, nut mixes, and breakfast jars deliberately placed outside the 2km radius.',
      pickupArea: 'Tiong Bahru',
      location: LatLng(1.2852, 103.8268),
    ),
  ];
}

List<V2CatalogItem> buildV2MockCatalogItems() {
  return [
    const V2CatalogItem(
      id: 'item-pandan-chiffon',
      storefrontId: 'sf-mika-bakes',
      name: 'Pandan chiffon cake',
      description: 'Soft pandan chiffon baked in whole-cake batches.',
      price: 18,
      availability: V2Availability.preorder,
    ),
    const V2CatalogItem(
      id: 'item-butter-cookies',
      storefrontId: 'sf-mika-bakes',
      name: 'Brown butter cookies',
      description: 'Nutty brown butter cookies with dark chocolate chunks.',
      price: 14,
    ),
    const V2CatalogItem(
      id: 'item-kueh-box',
      storefrontId: 'sf-nora-kitchen',
      name: 'Assorted kueh box',
      description: 'Ondeh-ondeh, kueh salat, and steamed tapioca slices.',
      price: 12,
    ),
    const V2CatalogItem(
      id: 'item-less-sweet-kueh',
      storefrontId: 'sf-nora-kitchen',
      name: 'Less sweet kueh set',
      description: 'A lighter sweetness sampler for tea-time pickups.',
      price: 13,
      availability: V2Availability.preorder,
    ),
    const V2CatalogItem(
      id: 'item-rosemary-focaccia',
      storefrontId: 'sf-loaf-lab',
      name: 'Rosemary focaccia slab',
      description: 'Olive oil focaccia with rosemary and flaky salt.',
      price: 16,
    ),
    const V2CatalogItem(
      id: 'item-mushroom-focaccia',
      storefrontId: 'sf-loaf-lab',
      name: 'Mushroom focaccia',
      description: 'Vegetarian focaccia with mushrooms and caramelised onion.',
      price: 18,
      availability: V2Availability.preorder,
    ),
    const V2CatalogItem(
      id: 'item-durian-puffs',
      storefrontId: 'sf-cream-corner',
      name: 'Mini durian puffs',
      description: 'Chilled mini puffs with D24 filling.',
      price: 22,
      availability: V2Availability.preorder,
    ),
    const V2CatalogItem(
      id: 'item-vanilla-puffs',
      storefrontId: 'sf-cream-corner',
      name: 'Vanilla cream puffs',
      description: 'Classic chilled puffs with vanilla pastry cream.',
      price: 16,
    ),
    const V2CatalogItem(
      id: 'item-granola-refill',
      storefrontId: 'sf-morning-jar',
      name: 'Granola refill pouch',
      description: 'Honey oat granola with almonds and dried fruit.',
      price: 10,
    ),
  ];
}

List<V2Subscription> buildV2MockSubscriptions() {
  return [
    const V2Subscription(
      id: 'sub-mika-alicia',
      userId: 'user-alicia',
      storefrontId: 'sf-mika-bakes',
    ),
    const V2Subscription(
      id: 'sub-mika-ben',
      userId: 'user-ben',
      storefrontId: 'sf-mika-bakes',
    ),
    const V2Subscription(
      id: 'sub-nora-you',
      userId: v2DemoUserId,
      storefrontId: 'sf-nora-kitchen',
    ),
    const V2Subscription(
      id: 'sub-nora-cheryl',
      userId: 'user-cheryl',
      storefrontId: 'sf-nora-kitchen',
    ),
    const V2Subscription(
      id: 'sub-loaf-dev',
      userId: 'user-dev',
      storefrontId: 'sf-loaf-lab',
    ),
    const V2Subscription(
      id: 'sub-loaf-elaine',
      userId: 'user-elaine',
      storefrontId: 'sf-loaf-lab',
    ),
    const V2Subscription(
      id: 'sub-loaf-farah',
      userId: 'user-farah',
      storefrontId: 'sf-loaf-lab',
    ),
    const V2Subscription(
      id: 'sub-cream-grace',
      userId: 'user-grace',
      storefrontId: 'sf-cream-corner',
    ),
  ];
}

List<V2Comment> buildV2MockComments() {
  final now = DateTime.now();

  return [
    V2Comment(
      id: 'comment-mika-01',
      storefrontId: 'sf-mika-bakes',
      userId: 'user-mika',
      body: 'Opening a cake batch if we hit 8 orders by Thursday.',
      createdAt: now.subtract(const Duration(hours: 4)),
    ),
    V2Comment(
      id: 'comment-mika-02',
      storefrontId: 'sf-mika-bakes',
      userId: 'user-alicia',
      body: 'I would like one whole cake for Friday evening.',
      createdAt: now.subtract(const Duration(hours: 2)),
    ),
    V2Comment(
      id: 'comment-nora-01',
      storefrontId: 'sf-nora-kitchen',
      userId: 'user-cheryl',
      body: 'Can you do less sweet?',
      createdAt: now.subtract(const Duration(hours: 1, minutes: 20)),
    ),
    V2Comment(
      id: 'comment-nora-02',
      storefrontId: 'sf-nora-kitchen',
      userId: 'user-nora',
      body: 'Yes, I can make this batch less sweet.',
      createdAt: now.subtract(const Duration(minutes: 45)),
    ),
    V2Comment(
      id: 'comment-loaf-01',
      storefrontId: 'sf-loaf-lab',
      userId: v2DemoUserId,
      body: 'Testing demand for a Friday bake. Minimum 6 slabs.',
      createdAt: now.subtract(const Duration(days: 1)),
    ),
    V2Comment(
      id: 'comment-loaf-02',
      storefrontId: 'sf-loaf-lab',
      userId: 'user-elaine',
      body: 'Any mushroom option?',
      createdAt: now.subtract(const Duration(hours: 2)),
    ),
    V2Comment(
      id: 'comment-cream-01',
      storefrontId: 'sf-cream-corner',
      userId: 'user-cream',
      body: 'Weekend puffs depend on supplier confirmation.',
      createdAt: now.subtract(const Duration(hours: 3)),
    ),
  ];
}
