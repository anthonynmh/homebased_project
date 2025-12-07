import 'package:flutter/material.dart';
import 'package:homebased_project/mvp2/app_components/app_card.dart';
import 'package:homebased_project/mvp2/app_components/app_text_field.dart';
import 'package:homebased_project/mvp2/app_components/app_form_button.dart';
import 'package:homebased_project/mvp2/app_components/app_action_menu.dart';
import 'package:homebased_project/mvp2/app_components/app_dialog.dart';

class MenuItemFormComponent extends StatelessWidget {
  final bool isEditing;
  final bool isNewItem;
  final TextEditingController nameController;
  final TextEditingController descController;
  final TextEditingController quantityController;
  final TextEditingController priceController;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;
  final VoidCallback? onEditToggle;

  const MenuItemFormComponent({
    super.key,
    required this.isEditing,
    required this.isNewItem,
    required this.nameController,
    required this.descController,
    required this.quantityController,
    required this.priceController,
    this.onSave,
    this.onCancel,
    this.onDelete,
    this.onEditToggle,
  });

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
                  "Item information",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                AppActionMenu(
                  items: [
                    AppActionMenuItem(
                      value: isEditing ? 'cancel' : 'edit',
                      label: isEditing ? 'Cancel' : 'Edit',
                      enabled: !isEditing,
                    ),
                    const AppActionMenuItem(
                      value: 'delete',
                      label: 'Delete Item',
                    ),
                  ],
                  onSelected: (value) async {
                    if (value == 'edit') onEditToggle?.call();
                    if (value == 'cancel') onCancel?.call();
                    if (value == 'delete') {
                      final confirmed = await showConfirmDialog(
                        context: context,
                        title: "Confirm Delete",
                        message:
                            "Are you sure you want to delete this item from your menu?",
                        cancelText: "Cancel",
                        confirmText: "Delete",
                      );
                      if (confirmed) onDelete?.call();
                    }
                  },
                ),
              ],
            ),
            AppTextField(
              label: 'Name',
              controller: nameController,
              readOnly: !(isEditing && isNewItem),
            ),
            AppTextField(
              label: 'Description',
              controller: descController,
              readOnly: !isEditing,
            ),
            AppTextField(
              label: 'Quantity',
              controller: quantityController,
              readOnly: !isEditing,
            ),
            AppTextField(
              label: 'Price',
              controller: priceController,
              readOnly: !isEditing,
            ),
            if (isEditing) AppFormButton(label: 'Save', onPressed: onSave),
          ],
        ),
      ),
    );
  }
}
