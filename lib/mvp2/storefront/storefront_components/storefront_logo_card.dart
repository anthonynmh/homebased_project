import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:homebased_project/backend/auth_api/auth_service.dart';
import 'package:homebased_project/mvp2/app_components/app_dialog.dart';
import 'package:homebased_project/mvp2/app_components/app_action_menu.dart';
import 'package:homebased_project/mvp2/app_components/app_card.dart';
import 'package:homebased_project/mvp2/storefront/storefront_data/storefront_service.dart';

class StorefrontLogoCard extends StatefulWidget {
  const StorefrontLogoCard({super.key});

  @override
  State<StorefrontLogoCard> createState() => _StorefrontLogoCardState();
}

class _StorefrontLogoCardState extends State<StorefrontLogoCard> {
  String? logoUrl;
  String? tempPath;
  XFile? tempImage;

  @override
  void initState() {
    super.initState();
    loadLogo();
  }

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
    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                "Storefront Logo",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              AppActionMenu(
                items: [
                  AppActionMenuItem(value: 'pick', label: 'Pick Logo Image'),
                  const AppActionMenuItem(
                    value: 'remove',
                    label: 'Remove Logo Image',
                  ),
                ],
                onSelected: (value) async {
                  if (value == 'pick') {
                    await pickLogo();
                  }

                  if (value == 'remove') {
                    final confirmed = await showConfirmDialog(
                      context: context,
                      title: "Confirm Remove",
                      message:
                          "Are you sure you want to remove this storefront logo image?",
                      cancelText: "Cancel",
                      confirmText: "Remove",
                    );

                    if (confirmed) {
                      await removeLogo();
                    }
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Image preview
          CircleAvatar(
            radius: 48,
            backgroundColor: Colors.white,
            backgroundImage: tempPath != null
                ? NetworkImage(tempPath!)
                : (logoUrl != null
                          ? NetworkImage(logoUrl!)
                          : const AssetImage('assets/ion_home.png'))
                      as ImageProvider,
          ),
        ],
      ),
    );
  }
}
