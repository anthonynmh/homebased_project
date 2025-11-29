import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:homebased_project/backend/auth_api/auth_service.dart';
import 'package:homebased_project/mvp2/main/main_components/main_snackbar_widget.dart';
import 'package:homebased_project/mvp2/app_components/app_page.dart';
import 'package:homebased_project/mvp2/app_components/app_form_button.dart';
import 'package:homebased_project/mvp2/storefront/storefront_components/storefront_prompt_card.dart';
import 'package:homebased_project/mvp2/storefront/storefront_components/storefront_info_card.dart';
import 'package:homebased_project/mvp2/storefront/storefront_components/storefront_logo_card.dart';
import 'package:homebased_project/mvp2/storefront/storefront_data/storefront_model.dart';
import 'package:homebased_project/mvp2/storefront/storefront_data/storefront_service.dart';

class StorefrontPage extends StatefulWidget {
  final void Function(String message)? onBroadcast;

  const StorefrontPage({super.key, this.onBroadcast});

  @override
  State<StorefrontPage> createState() => _StorefrontState();
}

class _StorefrontState extends State<StorefrontPage> {
  String? logoUrl;
  String? tempPath;
  XFile? tempImage;
  bool _isEditing = false;
  bool _hasStorefront = false;

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController(); // postal code

  @override
  void initState() {
    super.initState();
    loadLogo();
    loadStorefront();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // --- functions for logo card ---

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

  // --- functions for info card ---

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

  Future<Map<String, dynamic>> _getStorefrontFields() async {
    final rawPostal = _locationController.text.trim();

    if (rawPostal.isNotEmpty && !RegExp(r'^\d+$').hasMatch(rawPostal)) {
      final err = "Postal code must contain only numbers.";
      context.showSnackBar(err, isError: true);
      throw FormatException(err);
    }

    final parsedPostalCode = rawPostal.isEmpty ? null : int.parse(rawPostal);

    return {
      'businessName': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'photoUrls': null,
      'postalCode': parsedPostalCode,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    };
  }

  Future<void> createStorefront() async {
    final userId = authService.currentUserId;
    if (userId == null) return;

    try {
      final storefront = Storefront(
        id: userId,
        updatedAt: DateTime.now().toUtc().toIso8601String(),
      );

      await storefrontService.insertCurrentStorefront(storefront);
      print("storefront created successfully");
      setState(() {
        _hasStorefront = true;
      });

      widget.onBroadcast?.call("Storefront created.");
    } catch (e) {
      print("error creating storefront: $e");
    }
  }

  Future<void> updateStorefront() async {
    final userId = authService.currentUserId;
    if (userId == null) return;

    try {
      final data = await _getStorefrontFields();

      await storefrontService.updateCurrentStorefront(
        userId: userId,
        businessName: data['businessName'] as String?,
        description: data['description'] as String?,
        logoUrl: null,
        photoUrls: null,
        postalCode: data['postalCode'] as int?,
      );

      setState(() {
        _isEditing = false;
        _hasStorefront = true;
      });

      widget.onBroadcast?.call("Storefront updated.");
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
    return AppPage(
      title: 'Storefront Management',
      subtitle: 'Manage your store information and schedule',
      scrollable: true,
      action: AppFormButton(
        label: 'Broadcast',
        onPressed: () {},
        icon: const Icon(Icons.speaker_phone),
      ),
      child: Column(
        children: [
          if (!_hasStorefront) ...[
            StorefrontPromptCard(onCreate: createStorefront),
          ] else ...[
            StorefrontLogoCard(
              pickLogo: pickLogo,
              removeLogo: removeLogo,
              logoUrl: logoUrl,
              tempPath: tempPath,
              tempImage: tempImage,
            ),
            const SizedBox(height: 20),
            StorefrontInfoCard(
              isEditing: _isEditing,
              hasStorefront: _hasStorefront,
              nameController: _nameController,
              descriptionController: _descriptionController,
              locationController: _locationController,
              onSave: updateStorefront,
              onCancel: () => setState(() => _isEditing = false),
              onDelete: handleDelete,
              onEditToggle: () => setState(() => _isEditing = true),
            ),
          ],
        ],
      ),
    );
  }
}
