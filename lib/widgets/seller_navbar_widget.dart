import 'package:flutter/material.dart';

import 'package:homebased_project/data/notifiers.dart';
import 'package:homebased_project/mvp2/views/activity_feed/activity_feed_page.dart';
import 'package:homebased_project/mvp2/views/storefront/storefront_page.dart';
import 'package:homebased_project/mvp2/views/menu/menu_page.dart';
import 'package:homebased_project/mvp2/views/orders/orders_page.dart';
import 'package:homebased_project/mvp2/views/profile/profile_page.dart';

List<Widget> sellerPages = [
  ActivityFeedPage(),
  StorefrontPage(),
  MenuPage(),
  OrdersPage(),
  ProfilePage(),
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
            NavigationDestination(
              icon: const Icon(Icons.person_2_outlined),
              label: 'Profile',
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
