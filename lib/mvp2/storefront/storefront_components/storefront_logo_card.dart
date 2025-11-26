import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:homebased_project/backend/auth_api/auth_service.dart';
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

    final signed = await storefrontService.getStorefrontLogoUrl(userId);

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
        DateTime.now().toUtc().toIso8601String(),
      );

      final refreshed = await storefrontService.getStorefrontLogoUrl(
        authService.currentUserId!,
      );

      setState(() {
        logoUrl = refreshed;
        tempPath = null;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          const Text(
            "Store Logo",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

          const SizedBox(height: 12),

          ElevatedButton.icon(
            icon: const Icon(Icons.camera_alt, size: 18),
            label: const Text("Change Logo"),
            onPressed: pickLogo,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
              shape: const StadiumBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
