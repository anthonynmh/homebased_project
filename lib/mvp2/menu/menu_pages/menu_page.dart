import 'package:flutter/material.dart';
import 'package:homebased_project/backend/auth_api/auth_service.dart';
import 'package:homebased_project/mvp2/app_components/app_form_button.dart';
import 'package:homebased_project/mvp2/app_components/app_page.dart';
import 'package:homebased_project/mvp2/menu/menu_components/menu_item_card.dart';
import 'package:homebased_project/mvp2/menu/menu_data/menu_item_form_model.dart';
import 'package:homebased_project/mvp2/menu/menu_data/menu_service.dart';
import 'package:homebased_project/mvp2/menu/menu_data/menu_item_model.dart';
import 'package:homebased_project/mvp2/menu/menu_pages/menu_item_form.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<MenuItem> _menuItems = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }

  Future<void> _loadMenuItems() async {
    final userId = authService.currentUserId;
    if (userId == null) return;

    final items = await menuService.getUserMenuItems(userId);

    //Resolve photo URLs
    final resolved = <MenuItem>[];
    for (final item in items) {
      if (item.photoPath != null && item.photoPath!.isNotEmpty) {
        final url = await menuService.getMenuItemPhotoSignedUrl(
          item.userId,
          item.name,
        );
        resolved.add(item.copyWith(photoPath: url));
      } else {
        resolved.add(item);
      }
    }
    debugPrint('Resolved menu items: $resolved');
    setState(() {
      _menuItems = resolved;
      _loading = false;
    });
  }

  /* ---------------- CREATE ---------------- */

  Future<void> _openCreate() async {
    final userId = authService.currentUserId;
    if (userId == null) return;

    final result = await showModalBottomSheet<MenuItemFormResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const MenuItemFormScreen(),
    );

    if (result == null) return;

    final now = DateTime.now().toIso8601String();

    // 1️⃣ Insert menu item FIRST
    await menuService.insertMenuItem(
      result.item.copyWith(userId: userId, createdAt: now, updatedAt: now),
    );

    // 2️⃣ Upload photo ONLY if it exists
    if (result.photo != null) {
      await menuService.uploadMenuItemPhoto(
        imageFile: result.photo!,
        item: result.item,
      );
    }

    // 3️⃣ Refresh UI
    await _loadMenuItems();
  }

  /* ---------------- EDIT ---------------- */

  Future<void> _openEdit(MenuItem item) async {
    final result = await showModalBottomSheet<MenuItemFormResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => MenuItemFormScreen(menuItem: item),
    );

    final now = DateTime.now().toIso8601String();

    if (result == null) return;

    //get old photo path in case we need to delete it
    final oldFilePath = await menuService.getMenuItemPhotoFilepath(
      item.userId,
      item.name,
    );

    // 1️⃣ update menu item FIRST regardless of photo
    await menuService.updateMenuItem(result.item.copyWith(updatedAt: now));

    // 2️⃣ Upload photo ONLY if it exists
    if (result.photo != null) {
      await menuService.uploadMenuItemPhoto(
        imageFile: result.photo!,
        item: result.item,
      );
    } else {
      // If photo is null, assume user wants to remove existing photo
      if (oldFilePath != null && oldFilePath.isNotEmpty) {
        await menuService.deleteMenuItemPhotoByPath(oldFilePath);
      }
    }

    // 3️⃣ Refresh UI
    await _loadMenuItems();
  }

  /* ---------------- DELETE ---------------- */

  Future<void> _delete(MenuItem item) async {
    final userId = authService.currentUserId;
    if (userId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete menu item'),
        content: Text('Delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await menuService.deleteMenuItemPhoto(item);
      await menuService.deleteMenuItem(userId, item.name);
      _loadMenuItems();
    }
  }

  /* ---------------- UI ---------------- */

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Menu',
      subtitle: 'Manage your product offerings and updates',
      scrollable: true,
      child: Column(
        children: [
          const SizedBox(height: 16),

          if (_loading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            )
          else if (_menuItems.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text('No menu items yet'),
            )
          else
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: _menuItems.map((item) {
                debugPrint('Building MenuItemCard for item: $item');
                return SizedBox(
                  width: 320,
                  child: MenuItemCard(
                    item: item,
                    photoUrl: item.photoPath,
                    onEdit: () => _openEdit(item),
                    onDelete: () => _delete(item),
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 24),

          AppFormButton(
            label: 'Add Menu Item',
            icon: const Icon(Icons.add),
            onPressed: _openCreate,
          ),
        ],
      ),
    );
  }
}
