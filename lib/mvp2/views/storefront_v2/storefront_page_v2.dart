import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:homebased_project/backend/business_profile_api/business_profile_model.dart';
import 'package:homebased_project/backend/business_profile_api/business_profile_service.dart';
import 'package:homebased_project/backend/auth_api/auth_service.dart';

// components
import 'package:homebased_project/mvp2/app_components/app_text_field.dart';

class StorefrontPageV2 extends StatefulWidget {
  final void Function(String message)? onBroadcast;

  const StorefrontPageV2({super.key, this.onBroadcast});

  @override
  State<StorefrontPageV2> createState() => _StorefrontState();
}

class _StorefrontState extends State<StorefrontPageV2> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

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
    if (storefront == null) {
      debugPrint("no storefront found");
      return;
    }

    _nameController.text = storefront.businessName ?? '';
    _descriptionController.text = storefront.description ?? '';

    setState(() {
      _hasStorefront = true;
    });
  }

  Future<void> handleSave() async {
    final userId = authService.currentUserId;

    if (userId == null) {
      // handle error: user not logged in
      return;
    }

    final storefront = BusinessProfile(
      id: userId,
      updatedAt: DateTime.now().toUtc().toIso8601String(),
      businessName: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      photoUrls: null,
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

      if (widget.onBroadcast != null) {
        widget.onBroadcast!("Store profile created.");
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Storefront Management"),
        backgroundColor: Colors.white,
        elevation: 0.5,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(20),
          child: Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              "Manage your store information and schedule",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [_buildStoreInfoCard(context)]),
      ),
    );
  }

  Widget _buildStoreInfoCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Store Information",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                TextButton.icon(
                  icon: Icon(_isEditing ? Icons.close : Icons.edit, size: 18),
                  label: Text(_isEditing ? "Cancel" : "Edit"),
                  onPressed: () {
                    setState(() {
                      _isEditing = !_isEditing;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            AppTextField(
              label: "Store Name",
              controller: _nameController,
              icon: null,
              onChanged: _isEditing ? (_) {} : null,
              onComplete: _isEditing ? () {} : null,
              errorText: null,
              readOnly: !_isEditing,
            ),

            AppTextField(
              label: "Store Description",
              controller: _descriptionController,
              icon: null,
              onChanged: _isEditing ? (_) {} : null,
              onComplete: _isEditing ? () {} : null,
              errorText: null,
              readOnly: !_isEditing,
            ),

            AppTextField(
              label: "Store Location",
              controller: _locationController,
              icon: Icons.location_pin,
              onChanged: _isEditing ? (_) => setState(() {}) : null,
              onComplete: _isEditing ? () {} : null,
              errorText: null,
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
