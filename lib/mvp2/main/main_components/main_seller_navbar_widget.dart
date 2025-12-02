import 'package:flutter/material.dart';

import 'package:homebased_project/data/notifiers.dart';
import 'package:homebased_project/mvp2/activity_feed/activity_feed_pages/activity_feed_page.dart';
import 'package:homebased_project/mvp2/storefront/storefront_pages/storefront_page.dart';
import 'package:homebased_project/mvp2/menu/menu_pages/menu_page.dart';
import 'package:homebased_project/mvp2/views/orders/orders_page.dart';

List<Widget> sellerPages = [
  ActivityFeedPage(),
  StorefrontPage(),
  MenuPage(),
  OrdersPage(),
];

class SellerNavbarWidget extends StatelessWidget {
  const SellerNavbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedPageNotifier,
      builder: (context, selectedPage, child) {
        return NavigationBar(
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.feed_outlined),
              label: 'Activity Feed',
            ),
            NavigationDestination(
              icon: const Icon(Icons.store_outlined),
              label: 'Storefront',
            ),
            NavigationDestination(
              icon: const Icon(Icons.food_bank_outlined),
              label: 'Menu',
            ),
            NavigationDestination(
              icon: const Icon(Icons.mobile_friendly_outlined),
              label: 'Orders',
            ),
          ],
          onDestinationSelected: (int index) {
            selectedPageNotifier.value = index;
          },
          selectedIndex: selectedPage,
        );
      },
    );
  }
}
