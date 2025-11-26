import 'package:flutter/material.dart';

import 'package:homebased_project/mvp2/app_components/app_page.dart';
import 'package:homebased_project/mvp2/app_components/app_form_button.dart';
import 'package:homebased_project/mvp2/storefront/storefront_components/storefront_info_card.dart';
import 'package:homebased_project/mvp2/storefront/storefront_components/storefront_logo_card.dart';

class StorefrontPage extends StatefulWidget {
  final void Function(String message)? onBroadcast;

  const StorefrontPage({super.key, this.onBroadcast});

  @override
  State<StorefrontPage> createState() => _StorefrontState();
}

class _StorefrontState extends State<StorefrontPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Storefront Management',
      subtitle: 'Manage your store information and schedule',
      scrollable: true,
      action: AppFormButton(
        label: 'Broadcast',
        onPressed: () {},
        icon: const Icon(Icons.speaker_phone),
      ),
      child: Column(
        children: [
          StorefrontLogoCard(),
          const SizedBox(height: 20),
          StorefrontInfoCard(onBroadcast: widget.onBroadcast),
        ],
      ),
    );
  }
}
