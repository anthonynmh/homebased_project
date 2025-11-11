import 'package:flutter/material.dart';

import 'package:homebased_project/data/notifiers.dart';

List<Widget> defaultUserPages = [Placeholder(), Placeholder()];

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
