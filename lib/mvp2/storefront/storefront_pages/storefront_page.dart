import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:homebased_project/backend/auth_api/auth_service.dart';
import 'package:homebased_project/mvp2/app_components/app_page.dart';
import 'package:homebased_project/mvp2/app_components/app_form_button.dart';
import 'package:homebased_project/mvp2/storefront/storefront_components/storefront_info_card.dart';
import 'package:homebased_project/mvp2/storefront/storefront_components/storefront_logo_card.dart';
import 'package:homebased_project/mvp2/storefront/storefront_data/storefront_service.dart';

class StorefrontPage extends StatefulWidget {
  final void Function(String message)? onBroadcast;

  const StorefrontPage({super.key, this.onBroadcast});

  @override
  State<StorefrontPage> createState() => _StorefrontState();
}

class _StorefrontState extends State<StorefrontPage> {
  String? logoUrl;
  String? tempPath;
  XFile? tempImage;

  @override
  void initState() {
    super.initState();
    loadLogo();
  }

  // --- functions for logo card ---

  Future<void> loadLogo() async {
    final userId = authService.currentUserId;
    if (userId == null) return;

    final signed = await storefrontService.getStorefrontLogoSignedUrl(userId);

    if (!mounted) return;
    setState(() => logoUrl = signed);
  }

  Future<void> pickLogo() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked == null) return;

    setState(() {
      tempImage = picked;
      tempPath = picked.path;
    });

    try {
      await storefrontService.uploadStorefrontLogo(
        picked,
        authService.currentUserId!,
      );

      final refreshed = await storefrontService.getStorefrontLogoSignedUrl(
        authService.currentUserId!,
      );

      setState(() {
        logoUrl = refreshed;
        tempPath = null;
      });
    } catch (_) {}
  }

  Future<void> removeLogo() async {
    final userId = authService.currentUserId;
    if (userId == null) return;

    try {
      await storefrontService.deleteStorefrontLogo(userId);

      if (!mounted) return;
      setState(() {
        logoUrl = null;
        tempPath = null;
        tempImage = null;
      });
    } catch (_) {}
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
          StorefrontLogoCard(
            pickLogo: pickLogo,
            removeLogo: removeLogo,
            logoUrl: logoUrl,
            tempPath: tempPath,
            tempImage: tempImage,
          ),
          const SizedBox(height: 20),
          StorefrontInfoCard(onBroadcast: widget.onBroadcast),
        ],
      ),
    );
  }
}
