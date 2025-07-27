import 'package:flutter/material.dart';
import 'package:homebased_project/data/notifiers.dart';

class NavbarWidget extends StatelessWidget {
  const NavbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedPageNotifier,
      builder: (context, selectedPage, child) {
        return NavigationBar(
          destinations: [
            NavigationDestination(
              icon: ImageIcon(AssetImage('assets/searchIcon.png')),
              label: 'Explore',
            ),
            NavigationDestination(
              icon: ImageIcon(AssetImage('assets/defaultUser.png')),
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
