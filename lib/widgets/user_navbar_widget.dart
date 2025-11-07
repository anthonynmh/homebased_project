import 'package:flutter/material.dart';

import 'package:homebased_project/data/notifiers.dart';
import 'package:homebased_project/mvp2/views/profile/profile_page.dart';

List<Widget> defaultUserPages = [Placeholder(), Placeholder(), ProfilePage()];

class DefaultUserNavbarWidget extends StatelessWidget {
  const DefaultUserNavbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedPageNotifier,
      builder: (context, selectedPage, child) {
        return NavigationBar(
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.feed_outlined),
              label: 'Activity Feed',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_outlined),
              label: 'Search',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_2_outlined),
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
