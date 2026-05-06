import 'package:flutter_test/flutter_test.dart';

import 'package:homebased_project/v2/models/v2_marketplace.dart';
import 'package:homebased_project/v2/state/v2_app_controller.dart';

void main() {
  group('V2AppController storefront prototype', () {
    test('simulates auth and filters nearby storefronts to the 2km radius', () {
      final controller = V2AppController();

      expect(controller.isLoggedIn, isFalse);

      controller.simulateLogin(displayName: 'Alex');

      expect(controller.isLoggedIn, isTrue);
      expect(controller.currentUser?.displayName, 'Alex');
      expect(
        controller.nearbyStorefronts.length,
        lessThan(controller.allStorefronts.length),
      );
      expect(
        controller.nearbyStorefronts.every(
          (storefront) =>
              controller.distanceFromCurrentKm(storefront) <=
              controller.radiusKm,
        ),
        isTrue,
      );
    });

    test('subscribes, comments, and unsubscribes using frontend state', () {
      final controller = V2AppController()..simulateLogin(displayName: 'Alex');
      const storefrontId = 'sf-mika-bakes';

      expect(controller.isSubscribed(storefrontId), isFalse);
      expect(
        controller.postComment(
          storefrontId: storefrontId,
          body: 'Interested in the next batch.',
        ),
        isFalse,
      );

      controller.subscribe(storefrontId);

      expect(controller.isSubscribed(storefrontId), isTrue);
      expect(
        controller.postComment(
          storefrontId: storefrontId,
          body: 'Interested in the next batch.',
        ),
        isTrue,
      );
      expect(
        controller.commentsFor(storefrontId).last.body,
        'Interested in the next batch.',
      );

      controller.unsubscribe(storefrontId);

      expect(controller.isSubscribed(storefrontId), isFalse);
    });

    test('owner creates a storefront and manages catalog items', () {
      final controller = V2AppController()
        ..simulateSignup(displayName: 'Owner', userType: V2UserType.owner);

      final beforeOwned = controller.ownedStorefronts.length;

      controller.createStorefront(
        name: 'Owner Snacks',
        description: 'Simple snacks for nearby pickup.',
        pickupArea: 'Orchard',
      );

      final storefront = controller.ownedStorefronts.first;
      expect(controller.ownedStorefronts.length, beforeOwned + 1);
      expect(storefront.name, 'Owner Snacks');
      expect(controller.catalogFor(storefront.id), isNotEmpty);

      final item = controller.catalogFor(storefront.id).first;
      controller.updateCatalogItem(
        itemId: item.id,
        name: 'Edited snack box',
        description: 'Updated catalog item.',
        price: 15,
        availability: V2Availability.available,
      );

      expect(
        controller.catalogFor(storefront.id).first.name,
        'Edited snack box',
      );
    });
  });
}
