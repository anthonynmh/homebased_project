import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:homebased_project/mvp2/app_components/app_dialog.dart';
import 'package:homebased_project/mvp2/app_components/app_action_menu.dart';
import 'package:homebased_project/mvp2/app_components/app_card.dart';

class StorefrontLogoCard extends StatelessWidget {
  final VoidCallback pickLogo;
  final VoidCallback removeLogo;
  final String? logoUrl;
  final String? tempPath;
  final XFile? tempImage;

  const StorefrontLogoCard({
    super.key,
    required this.pickLogo,
    required this.removeLogo,
    this.logoUrl,
    this.tempPath,
    this.tempImage,
  });

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
                    pickLogo();
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
                      removeLogo();
                    }
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

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
