import 'package:flutter/material.dart';

import 'package:homebased_project/v2/models/v2_marketplace.dart';
import 'package:homebased_project/v2/screens/v2_account_screen.dart';
import 'package:homebased_project/v2/screens/v2_activity_screen.dart';
import 'package:homebased_project/v2/screens/v2_auth_screen.dart';
import 'package:homebased_project/v2/screens/v2_discover_screen.dart';
import 'package:homebased_project/v2/screens/v2_owner_community_screen.dart';
import 'package:homebased_project/v2/screens/v2_owner_products_screen.dart';
import 'package:homebased_project/v2/screens/v2_owner_store_screen.dart';
import 'package:homebased_project/v2/screens/v2_subscribed_screen.dart';
import 'package:homebased_project/v2/state/v2_app_controller.dart';

class V2HomeShell extends StatefulWidget {
  const V2HomeShell({super.key});

  @override
  State<V2HomeShell> createState() => _V2HomeShellState();
}

class _V2HomeShellState extends State<V2HomeShell> {
  late final V2AppController _controller;
  int _selectedIndex = 0;
  V2UserType _lastUserType = V2UserType.casual;

  @override
  void initState() {
    super.initState();
    _controller = V2AppController();
    _controller.addListener(_handleControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (!_controller.isLoggedIn) {
          return V2AuthScreen(controller: _controller);
        }

        final ownerMode = _controller.userType == V2UserType.owner;
        final screens = ownerMode
            ? [
                V2OwnerStoreScreen(controller: _controller),
                V2OwnerProductsScreen(controller: _controller),
                V2OwnerCommunityScreen(controller: _controller),
                V2AccountScreen(
                  controller: _controller,
                  onModeChanged: _resetTab,
                ),
              ]
            : [
                V2DiscoverScreen(controller: _controller),
                V2SubscribedScreen(controller: _controller),
                V2ActivityScreen(controller: _controller),
                V2AccountScreen(
                  controller: _controller,
                  onModeChanged: _resetTab,
                ),
              ];

        return Scaffold(
          body: IndexedStack(index: _selectedIndex, children: screens),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            destinations: ownerMode
                ? const [
                    NavigationDestination(
                      icon: Icon(Icons.storefront_outlined),
                      selectedIcon: Icon(Icons.storefront),
                      label: 'Stores',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.inventory_2_outlined),
                      selectedIcon: Icon(Icons.inventory_2),
                      label: 'Products',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.forum_outlined),
                      selectedIcon: Icon(Icons.forum),
                      label: 'Community',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: 'Account',
                    ),
                  ]
                : const [
                    NavigationDestination(
                      icon: Icon(Icons.explore_outlined),
                      selectedIcon: Icon(Icons.explore),
                      label: 'Discover',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.notifications_none),
                      selectedIcon: Icon(Icons.notifications_active),
                      label: 'Subscribed',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.inbox_outlined),
                      selectedIcon: Icon(Icons.inbox),
                      label: 'Activity',
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

  void _handleControllerChanged() {
    if (!_controller.isLoggedIn) {
      if (_selectedIndex != 0) setState(() => _selectedIndex = 0);
      return;
    }
    if (_controller.userType != _lastUserType) {
      _lastUserType = _controller.userType;
      _resetTab();
    }
  }

  void _resetTab() {
    if (mounted) setState(() => _selectedIndex = 0);
  }
}
