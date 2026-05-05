import 'package:flutter/material.dart';

import 'package:homebased_project/v2/screens/v2_account_screen.dart';
import 'package:homebased_project/v2/screens/v2_listings_screen.dart';
import 'package:homebased_project/v2/screens/v2_map_screen.dart';
import 'package:homebased_project/v2/state/v2_app_controller.dart';

class V2HomeShell extends StatefulWidget {
  const V2HomeShell({super.key});

  @override
  State<V2HomeShell> createState() => _V2HomeShellState();
}

class _V2HomeShellState extends State<V2HomeShell> {
  late final V2AppController _controller;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = V2AppController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              V2MapScreen(controller: _controller),
              V2ListingsScreen(controller: _controller),
              V2AccountScreen(controller: _controller),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.map_outlined),
                selectedIcon: Icon(Icons.map),
                label: 'Map',
              ),
              NavigationDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2),
                label: 'Listings',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Account',
              ),
            ],
          ),
        );
      },
    );
  }
}
