import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:homebased_project/backend/auth_api/auth_service.dart';
import 'package:homebased_project/mvp2/storefront/storefront_data/storefront_model.dart';
import 'package:homebased_project/mvp2/storefront/storefront_data/storefront_service.dart';
import 'package:homebased_project/mvp2/main/main_components/main_snackbar_widget.dart';
import 'package:homebased_project/mvp2/app_components/app_action_menu.dart';
import 'package:homebased_project/mvp2/app_components/app_dialog.dart';
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

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> loadStorefront() async {
    final userId = authService.currentUserId;
    if (userId == null) return;

    final storefront = await storefrontService.getCurrentStorefront(userId);
    if (storefront == null) return;

    _nameController.text = storefront.businessName ?? '';
    _descriptionController.text = storefront.description ?? '';
    _locationController.text = storefront.postalCode?.toString() ?? '';

    setState(() {
      _hasStorefront = true;
    });
  }

  Future<Storefront> _buildStorefront(String userId) async {
    final rawPostal = _locationController.text.trim();

    if (rawPostal.isNotEmpty && !RegExp(r'^\d+$').hasMatch(rawPostal)) {
      String err = "Postal code must contain only numbers.";
      context.showSnackBar(err, isError: true);
      throw FormatException(err);
    }

    final parsedPostalCode = rawPostal.isEmpty ? null : int.parse(rawPostal);

    return Storefront(
      id: userId,
      updatedAt: DateTime.now().toUtc().toIso8601String(),
      businessName: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      photoUrls: null,
      postalCode: parsedPostalCode,
    );
  }

  Future<void> createStorefront() async {
    final userId = authService.currentUserId;
    if (userId == null) return;

    final storefront = await _buildStorefront(userId);
    await storefrontService.insertCurrentStorefront(storefront);

    setState(() {
      _hasStorefront = true;
    });

    widget.onBroadcast?.call("Storefront created.");
  }

  Future<void> updateStorefront() async {
    final userId = authService.currentUserId;
    if (userId == null) return;

    final storefront = await _buildStorefront(userId);
    await storefrontService.updateCurrentStorefront(storefront);

    widget.onBroadcast?.call("Storefront updated.");
  }

  Future<void> handleSave() async {
    try {
      if (_hasStorefront) {
        await updateStorefront();
      } else {
        await createStorefront();
      }

      setState(() {
        _isEditing = false;
        _hasStorefront = true;
      });
    } catch (_) {}
  }

  Future<void> handleDelete() async {
    final userId = authService.currentUserId;
    if (userId == null) return;

    try {
      await storefrontService.deleteCurrentStorefront(userId);

      setState(() {
        _hasStorefront = false;
        _isEditing = false;
        _nameController.clear();
        _descriptionController.clear();
        _locationController.clear();
      });

      widget.onBroadcast?.call("Storefront deleted.");
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasStorefront) {
      return AppCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Store Information",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              const Text("You have not created a storefront yet."),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  shape: const StadiumBorder(),
                ),
                onPressed: createStorefront,
                child: const Text("Create Storefront"),
              ),
            ],
          ),
        ),
      );
    }
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
                const Spacer(),
                AppActionMenu(
                  items: [
                    AppActionMenuItem(
                      value: 'edit',
                      label: 'Edit',
                      enabled: !_isEditing,
                    ),
                    const AppActionMenuItem(
                      value: 'delete',
                      label: 'Delete Storefront',
                    ),
                  ],
                  onSelected: (value) async {
                    if (value == 'edit') {
                      setState(() => _isEditing = !_isEditing);
                    }

                    if (value == 'delete') {
                      final confirmed = await showConfirmDialog(
                        context: context,
                        title: "Confirm Delete",
                        message:
                            "Are you sure you want to delete this storefront?",
                        cancelText: "Cancel",
                        confirmText: "Delete",
                      );

                      if (confirmed) {
                        await handleDelete();
                      }
                    }
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () {
                      setState(() => _isEditing = !_isEditing);
                    },
                    child: const Text("Cancel"),
                  ),
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
          ],
        ),
      ),
    );
  }
}
