import 'package:flutter/material.dart';

import 'package:homebased_project/data/notifiers.dart';
import 'package:homebased_project/backend/auth_api/auth_service.dart';
import 'package:homebased_project/mvp2/main/main_components/main_seller_navbar_widget.dart';
import 'package:homebased_project/mvp2/main/main_components/main_user_navbar_widget.dart';
import 'package:homebased_project/mvp2/auth/auth_pages/auth_page.dart';
import 'package:homebased_project/mvp2/profile/profile_pages/profile_app_bar_section.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  void _switchProfileMode() {
    setState(() {
      userMode.value = userMode.value == 'Seller' ? 'User' : 'Seller';
    });
    setUserMode(userMode.value);
  }

  void _logout() async {
    await authService.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ProfileAppBarSection(
        profileMode: userMode.value,
        onSwitchMode: _switchProfileMode,
        onLogout: _logout,
      ),

      body: ValueListenableBuilder<String>(
        valueListenable: userMode,
        builder: (context, mode, child) {
          return ValueListenableBuilder<int>(
            valueListenable: selectedPageNotifier,
            builder: (context, selectedIndex, _) {
              final pages = mode == "Seller" ? sellerPages : defaultUserPages;
              return pages.elementAt(selectedIndex);
            },
          );
        },
      ),

      bottomNavigationBar: ValueListenableBuilder<String>(
        valueListenable: userMode,
        builder: (context, mode, child) {
          return mode == "Seller"
              ? const SellerNavbarWidget()
              : const DefaultUserNavbarWidget();
        },
      ),
    );
  }
}
