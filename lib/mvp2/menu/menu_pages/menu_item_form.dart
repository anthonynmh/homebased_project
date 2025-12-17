import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:homebased_project/backend/auth_api/auth_service.dart';
import 'package:homebased_project/mvp2/app_components/app_action_button.dart';
import 'package:homebased_project/mvp2/app_components/app_card.dart';
import 'package:homebased_project/mvp2/app_components/app_photo_section.dart';
import 'package:homebased_project/mvp2/app_components/app_text_field.dart';
import 'package:homebased_project/mvp2/menu/menu_data/menu_item_form_model.dart';
import 'package:homebased_project/mvp2/menu/menu_data/menu_item_model.dart';

class MenuItemFormScreen extends StatefulWidget {
  final MenuItem? menuItem;

  const MenuItemFormScreen({super.key, this.menuItem});

  @override
  State<MenuItemFormScreen> createState() => _MenuItemFormScreenState();
}

class _MenuItemFormScreenState extends State<MenuItemFormScreen> {
  late final TextEditingController nameController;
  late final TextEditingController descController;
  late final TextEditingController quantityController;
  late final TextEditingController priceController;

  XFile? _newPhoto;
  String? _signedPhotoUrl; // remote preview only

  final _picker = ImagePicker();

  bool get _isEditing => widget.menuItem != null;

  ImageProvider? get _networkPhoto =>
      _signedPhotoUrl != null ? NetworkImage(_signedPhotoUrl!) : null;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.menuItem?.name ?? '');
    descController = TextEditingController(
      text: widget.menuItem?.description ?? '',
    );
    quantityController = TextEditingController(
      text: widget.menuItem?.quantity?.toString() ?? '',
    );
    priceController = TextEditingController(
      text: widget.menuItem?.price?.toString() ?? '',
    );

    // IMPORTANT: menuItem.photoPath must already be a SIGNED URL here
    _signedPhotoUrl = widget.menuItem?.photoPath;
  }

  Future<void> _pickPhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked == null) return;

    debugPrint('PICKED IMAGE PATH: ${picked.path}');

    setState(() {
      _newPhoto = picked;
      _signedPhotoUrl = null; // override remote preview
    });
  }

  void _removePhoto() {
    setState(() {
      _newPhoto = null;
      _signedPhotoUrl = null;
    });
  }

  void _onSave() {
    final userId = authService.currentUserId;
    if (userId == null) return;

    final now = DateTime.now().toUtc().toIso8601String();

    final item = MenuItem(
      userId: userId,
      name: nameController.text.trim(),
      description: descController.text.trim(),
      quantity: int.tryParse(quantityController.text) ?? 0,
      price: double.tryParse(priceController.text) ?? 0.0,
      createdAt: widget.menuItem?.createdAt ?? now,
      updatedAt: now,
      photoPath: null, // DO NOT store signed URLs in DB
    );

    Navigator.pop(context, MenuItemFormResult(item: item, photo: _newPhoto));
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      'FORM BUILD → newPhoto=${_newPhoto?.path}, signedUrl=$_signedPhotoUrl',
    );
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: AppCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /* ---------- HEADER ---------- */
                Row(
                  children: [
                    Text(
                      _isEditing ? 'Edit Menu Item' : 'Create Menu Item',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                /* ---------- PHOTO ---------- */
                AppPhotoSection(
                  localFile: _newPhoto, // 👈 immediate preview
                  image: _networkPhoto, // 👈 signed URL
                  onTap: _pickPhoto,
                  onEdit: _pickPhoto,
                  onDelete: _removePhoto,
                ),

                const SizedBox(height: 16),

                /* ---------- FORM ---------- */
                AppTextField(
                  label: 'Name (cannot be edited once created)',
                  controller: nameController,
                  readOnly: _isEditing,
                ),
                AppTextField(label: 'Description', controller: descController),
                AppTextField(label: 'Quantity', controller: quantityController),
                AppTextField(label: 'Price', controller: priceController),

                const SizedBox(height: 24),

                /* ---------- ACTIONS ---------- */
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppActionButton(
                      label: 'Cancel',
                      icon: Icons.close,
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    AppActionButton(
                      label: 'Save',
                      icon: Icons.save,
                      onPressed: _onSave,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
