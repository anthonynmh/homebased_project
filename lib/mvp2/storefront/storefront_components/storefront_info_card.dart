import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:homebased_project/backend/auth_api/auth_service.dart';
import 'package:homebased_project/backend/business_profile_api/business_profile_model.dart';
import 'package:homebased_project/backend/business_profile_api/business_profile_service.dart';
import 'package:homebased_project/mvp2/app_components/app_card.dart';
import 'package:homebased_project/mvp2/app_components/app_text_field.dart';

class StorefrontInfoCard extends StatefulWidget {
  final void Function(String message)? onBroadcast;

  const StorefrontInfoCard({super.key, this.onBroadcast});

  @override
  State<StorefrontInfoCard> createState() => _StorefrontInfoCardState();
}

class _StorefrontInfoCardState extends State<StorefrontInfoCard> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController(); // postal code

  bool _isEditing = false;
  bool _hasStorefront = false;

  @override
  void initState() {
    super.initState();
    loadStorefront();
  }

  Future<void> loadStorefront() async {
    final userId = authService.currentUserId;
    if (userId == null) return;

    final storefront = await businessProfileService.getCurrentBusinessProfile(
      userId,
    );
    if (storefront == null) return;

    _nameController.text = storefront.businessName ?? '';
    _descriptionController.text = storefront.description ?? '';
    _locationController.text = storefront.postalCode?.toString() ?? '';

    setState(() {
      _hasStorefront = true;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> handleSave() async {
    final userId = authService.currentUserId;
    if (userId == null) return;

    final parsedPostalCode = int.tryParse(_locationController.text.trim());

    final storefront = BusinessProfile(
      id: userId,
      updatedAt: DateTime.now().toUtc().toIso8601String(),
      businessName: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      photoUrls: null,
      postalCode: parsedPostalCode,
    );

    try {
      if (_hasStorefront) {
        await businessProfileService.updateCurrentBusinessProfile(storefront);
      } else {
        await businessProfileService.insertCurrentBusinessProfile(storefront);
      }

      setState(() {
        _isEditing = false;
      });

      widget.onBroadcast?.call("Store profile saved.");
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  "Store Information",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                TextButton.icon(
                  icon: Icon(_isEditing ? Icons.close : Icons.edit, size: 18),
                  label: Text(_isEditing ? "Cancel" : "Edit"),
                  onPressed: () {
                    setState(() => _isEditing = !_isEditing);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            AppTextField(
              label: "Store Name",
              controller: _nameController,
              readOnly: !_isEditing,
            ),

            AppTextField(
              label: "Store Description",
              controller: _descriptionController,
              readOnly: !_isEditing,
            ),

            AppTextField(
              label: "Postal Code",
              controller: _locationController,
              icon: Icons.location_pin,
              onChanged: _isEditing ? (_) => setState(() {}) : null,
              readOnly: !_isEditing,
            ),

            if (_locationController.text.isNotEmpty)
              TextButton.icon(
                icon: const Icon(Icons.map_outlined, size: 18),
                label: const Text("View on Google Maps"),
                onPressed: () async {
                  final query = Uri.encodeComponent(_locationController.text);
                  final url = Uri.parse(
                    'https://www.google.com/maps/search/?api=1&query=$query',
                  );
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
              ),

            const SizedBox(height: 12),

            if (_isEditing)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  shape: const StadiumBorder(),
                ),
                onPressed: handleSave,
                child: const Text("Save Changes"),
              ),
          ],
        ),
      ),
    );
  }
}
