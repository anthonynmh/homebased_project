import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:homebased_project/v2/models/v2_marketplace.dart';
import 'package:homebased_project/v2/screens/v2_discover_screen.dart';
import 'package:homebased_project/v2/screens/v2_storefront_detail_screen.dart';
import 'package:homebased_project/v2/screens/v2_subscribed_screen.dart';
import 'package:homebased_project/v2/state/v2_app_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Discover searches storefronts by product text', (tester) async {
    final controller = V2AppController(loadPersistedState: false)
      ..simulateLogin(displayName: 'Alex');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: V2DiscoverScreen(controller: controller)),
      ),
    );

    expect(find.text('Discover'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'mushroom focaccia');
    await tester.pump();

    expect(find.text('Loaf Lab'), findsOneWidget);
    expect(find.text('Mika Bakes'), findsNothing);
  });

  testWidgets('Subscribed empty state guides users back to Discover', (
    tester,
  ) async {
    var explored = false;
    final controller = V2AppController(loadPersistedState: false)
      ..simulateLogin(displayName: 'Alex')
      ..unsubscribe('sf-nora-kitchen');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: V2SubscribedScreen(
            controller: controller,
            onExplore: () => explored = true,
          ),
        ),
      ),
    );

    expect(find.text('No subscriptions yet'), findsOneWidget);
    await tester.ensureVisible(find.text('Explore storefronts'));
    await tester.tap(find.text('Explore storefronts'));

    expect(explored, isTrue);
  });

  testWidgets('Storefront detail separates live products from demand tests', (
    tester,
  ) async {
    final controller = V2AppController(loadPersistedState: false)
      ..simulateLogin(displayName: 'Alex', userType: V2UserType.owner);

    await tester.pumpWidget(
      MaterialApp(
        home: V2StorefrontDetailScreen(
          controller: controller,
          storefrontId: 'sf-loaf-lab',
        ),
      ),
    );

    expect(find.text('Available now'), findsWidgets);
    expect(find.text('Testing demand'), findsWidgets);
    expect(find.text('Rosemary focaccia slab'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Mushroom focaccia'),
      260,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Mushroom focaccia'), findsOneWidget);
  });
}
