import 'package:flutter/material.dart';

import 'package:homebased_project/data/notifiers.dart';
import 'package:homebased_project/mvp2/main/main_components/main_seller_navbar_widget.dart';
import 'package:homebased_project/mvp2/main/main_components/main_user_navbar_widget.dart';
import 'package:homebased_project/mvp2/profile/profile_pages/profile_app_bar_section.dart';

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ProfileAppBarSection(),

      body: ValueListenableBuilder<String>(
        valueListenable: userMode,
        builder: (context, mode, _) {
          return ValueListenableBuilder<int>(
            valueListenable: selectedPageNotifier,
            builder: (context, selectedIndex, __) {
              final pages = mode == "Seller" ? sellerPages : defaultUserPages;
              return pages.elementAt(selectedIndex);
            },
          );
        },
      ),

      bottomNavigationBar: ValueListenableBuilder<String>(
        valueListenable: userMode,
        builder: (context, mode, _) {
          return mode == "Seller"
              ? const SellerNavbarWidget()
              : const DefaultUserNavbarWidget();
        },
      ),
    );
  }
}
