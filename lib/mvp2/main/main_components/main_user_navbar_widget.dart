import 'package:flutter/material.dart';

import 'package:homebased_project/data/notifiers.dart';
import 'package:homebased_project/mvp2/search/search_pages/search_page.dart';

List<Widget> defaultUserPages = [Placeholder(), SearchPage(), Placeholder()];

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
              icon: Icon(Icons.rotate_90_degrees_ccw_outlined),
              label: 'Catch Up',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_outlined),
              label: 'Search',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_border_outlined),
              label: 'Followed HBBs',
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
