import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:homebased_project/mvp2/app_components/app_form_button.dart';
import 'package:homebased_project/mvp2/app_components/app_action_menu.dart';
import 'package:homebased_project/mvp2/app_components/app_dialog.dart';
import 'package:homebased_project/mvp2/app_components/app_card.dart';
import 'package:homebased_project/mvp2/app_components/app_text_field.dart';

class StorefrontInfoCard extends StatelessWidget {
  final bool isEditing;
  final bool hasStorefront;

  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController locationController;

  final VoidCallback? onCreate;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;
  final Future<void> Function()? onDelete;
  final VoidCallback? onEditToggle;

  const StorefrontInfoCard({
    super.key,
    required this.isEditing,
    required this.hasStorefront,
    required this.nameController,
    required this.descriptionController,
    required this.locationController,
    this.onCreate,
    this.onSave,
    this.onCancel,
    this.onDelete,
    this.onEditToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasStorefront) {
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
              AppFormButton(
                label: "Create Storefront",
                onPressed: onCreate,
                icon: const Icon(Icons.add),
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
                      enabled: !isEditing,
                    ),
                    const AppActionMenuItem(
                      value: 'delete',
                      label: 'Delete Storefront',
                    ),
                  ],
                  onSelected: (value) async {
                    if (value == 'edit') {
                      onEditToggle?.call();
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
                        await onDelete?.call();
                      }
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: "Store Name",
              controller: nameController,
              readOnly: !isEditing,
            ),
            AppTextField(
              label: "Store Description",
              controller: descriptionController,
              readOnly: !isEditing,
            ),
            AppTextField(
              label: "Postal Code",
              controller: locationController,
              icon: Icons.location_pin,
              readOnly: !isEditing,
            ),
            if (locationController.text.isNotEmpty)
              TextButton.icon(
                icon: const Icon(Icons.map_outlined, size: 18),
                label: const Text("View on Google Maps"),
                onPressed: () async {
                  final query = Uri.encodeComponent(locationController.text);
                  final url = Uri.parse(
                    'https://www.google.com/maps/search/?api=1&query=$query',
                  );
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
              ),
            const SizedBox(height: 12),
            if (isEditing)
              Row(
                children: [
                  Expanded(
                    child: AppFormButton(
                      label: "Cancel",
                      backgroundColor: Colors.grey,
                      onPressed: onCancel,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppFormButton(
                      label: "Save Changes",
                      onPressed: onSave,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
