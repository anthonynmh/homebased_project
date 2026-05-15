import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:homebased_project/v2/models/v2_marketplace.dart';
import 'package:homebased_project/v2/state/v2_app_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('V2AppController storefront prototype', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('simulates auth and account type selection', () {
      final controller = V2AppController(loadPersistedState: false);

      expect(controller.isLoggedIn, isFalse);

      controller.simulateLogin(
        displayName: 'Alex',
        email: 'alex@example.test',
        userType: V2UserType.owner,
      );

      expect(controller.isLoggedIn, isTrue);
      expect(controller.currentUser?.displayName, 'Alex');
      expect(controller.currentUser?.email, 'alex@example.test');
      expect(controller.userType, V2UserType.owner);
      expect(controller.ownerStorefront?.name, 'Loaf Lab');
    });

    test('switches modes and filters nearby storefronts to radius', () {
      final controller = V2AppController(loadPersistedState: false)
        ..simulateLogin(displayName: 'Alex');

      expect(controller.userType, V2UserType.casual);
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

      controller.setUserType(V2UserType.owner);

      expect(controller.userType, V2UserType.owner);
    });

    test('subscribes, replies to discussions, and unsubscribes', () {
      final controller = V2AppController(loadPersistedState: false)
        ..simulateLogin(displayName: 'Alex');
      const storefrontId = 'sf-mika-bakes';
      final thread = controller.threadsForStorefront(storefrontId).first;

      expect(controller.isSubscribed(storefrontId), isFalse);
      expect(
        controller.postThreadReply(
          threadId: thread.id,
          body: 'Interested in the next batch.',
        ),
        isFalse,
      );

      controller.subscribe(storefrontId);

      expect(controller.isSubscribed(storefrontId), isTrue);
      expect(
        controller.postThreadReply(
          threadId: thread.id,
          body: 'Interested in the next batch.',
        ),
        isTrue,
      );
      expect(
        controller.commentsForThread(thread.id).last.body,
        'Interested in the next batch.',
      );

      controller.unsubscribe(storefrontId);

      expect(controller.isSubscribed(storefrontId), isFalse);
    });

    test('owner creates, edits, and deletes live and upcoming products', () {
      final controller = V2AppController(loadPersistedState: false)
        ..simulateSignup(displayName: 'Owner', userType: V2UserType.owner);
      final storefront = controller.ownerStorefront!;

      controller.addCatalogItem(
        storefrontId: storefront.id,
        name: 'Fresh tart',
        description: 'Lemon tart for pickup.',
        price: 9,
        category: 'Tarts',
        status: V2ProductStatus.live,
        imageUrl: 'https://example.test/tart.jpg',
      );
      controller.addCatalogItem(
        storefrontId: storefront.id,
        name: 'Weekend bun',
        description: 'A Saturday-only bun.',
        price: 7,
        category: 'Bread',
        status: V2ProductStatus.upcoming,
      );

      expect(
        controller.productsFor(storefront.id, status: V2ProductStatus.live),
        isNotEmpty,
      );
      expect(
        controller.productsFor(storefront.id, status: V2ProductStatus.upcoming),
        isNotEmpty,
      );

      final item = controller.catalogFor(storefront.id).last;
      controller.updateCatalogItem(
        itemId: item.id,
        name: 'Edited weekend bun',
        description: 'Updated catalog item.',
        price: 8,
        category: 'Buns',
        status: V2ProductStatus.live,
      );

      expect(controller.catalogItemById(item.id)?.name, 'Edited weekend bun');
      expect(controller.catalogItemById(item.id)?.status, V2ProductStatus.live);

      controller.deleteCatalogItem(item.id);

      expect(controller.catalogItemById(item.id), isNull);
    });

    test('marks notifications as read', () {
      final controller = V2AppController(loadPersistedState: false)
        ..simulateLogin(displayName: 'Alex');

      expect(controller.unreadNotificationCount, greaterThan(0));

      controller.markAllNotificationsRead();

      expect(controller.unreadNotificationCount, 0);
      expect(controller.notifications.every((item) => item.read), isTrue);
    });

    test('restores useful prototype state from shared preferences', () async {
      final controller = V2AppController(loadPersistedState: false)
        ..simulateLogin(displayName: 'Alex')
        ..subscribe('sf-mika-bakes')
        ..markAllNotificationsRead();

      await Future<void>.delayed(Duration.zero);

      final restored = V2AppController(loadPersistedState: false);
      await restored.loadPersistedStateFromDisk();

      expect(restored.isLoggedIn, isTrue);
      expect(restored.currentUser?.displayName, 'Alex');
      expect(restored.isSubscribed('sf-mika-bakes'), isTrue);
      expect(restored.unreadNotificationCount, 0);

      await controller.deleteMockAccount();
      await Future<void>.delayed(Duration.zero);

      final cleared = V2AppController(loadPersistedState: false);
      await cleared.loadPersistedStateFromDisk();

      expect(cleared.isLoggedIn, isFalse);
    });
  });
}
