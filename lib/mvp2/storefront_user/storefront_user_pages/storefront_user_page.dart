import 'package:flutter/material.dart';

import 'package:homebased_project/mvp2/app_components/app_page.dart';
import 'package:homebased_project/mvp2/storefront_seller/storefront_data/storefront_model.dart';
import 'package:homebased_project/mvp2/storefront_seller/storefront_data/storefront_service.dart';

class StorefrontUserPage extends StatefulWidget {
  final String
  storefrontUserId; // seller/user id whose storefront is being viewed

  const StorefrontUserPage({super.key, required this.storefrontUserId});

  @override
  State<StorefrontUserPage> createState() => _StorefrontUserPageState();
}

class _StorefrontUserPageState extends State<StorefrontUserPage> {
  Storefront? storefront;
  String? logoUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadStorefront();
  }

  Future<void> loadStorefront() async {
    try {
      final data = await storefrontService.getCurrentStorefront(
        widget.storefrontUserId,
      );

      final signedLogo = await storefrontService.getStorefrontLogoSignedUrl(
        widget.storefrontUserId,
      );

      if (!mounted) return;

      setState(() {
        storefront = data;
        logoUrl = signedLogo;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Storefront',
      subtitle: 'Business information',
      scrollable: true,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : storefront == null
          ? const Center(child: Text('Storefront not available'))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Logo ---
                if (logoUrl != null)
                  Center(
                    child: CircleAvatar(
                      radius: 48,
                      backgroundImage: NetworkImage(logoUrl!),
                    ),
                  ),
                const SizedBox(height: 20),

                // --- Business Name ---
                Text(
                  storefront!.businessName ?? '',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),

                // --- Description ---
                if ((storefront!.description ?? '').isNotEmpty)
                  Text(
                    storefront!.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                const SizedBox(height: 20),

                // --- Location ---
                if (storefront!.postalCode != null)
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        storefront!.postalCode.toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),

                // --- Future sections ---
                // • product list
                // • schedule / availability
                // • contact / follow / message button
              ],
            ),
    );
  }
}
