import 'package:flutter/material.dart';
import 'package:homebased_project/backend/auth_api/auth_service.dart';
import 'package:homebased_project/mvp2/app_components/app_form_button.dart';
import 'package:homebased_project/mvp2/app_components/app_page.dart';
import 'package:homebased_project/mvp2/menu/menu_data/menu_service.dart';
import 'package:homebased_project/mvp2/menu/menu_pages/menu_item_form.dart';
import 'package:homebased_project/mvp2/menu/menu_data/menu_item_model.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<MenuItem> _menuItems = [];
  bool _isAddingNew = false;

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }

  Future<void> _loadMenuItems() async {
    final userId = authService.currentUserId;
    if (userId == null) return;

    final items = await menuService.getUserMenuItems(userId);
    setState(() {
      _menuItems = items;
      _isAddingNew = false; // reset when loaded
    });
  }

  void _addNewForm() {
    if (_isAddingNew) return; // block multiple new forms

    final userId = authService.currentUserId;
    if (userId == null) return;

    setState(() {
      _menuItems.add(
        MenuItem(
          userId: userId,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          name: "",
          description: "",
          quantity: 0,
          price: 0.0,
        ),
      );
      _isAddingNew = true;
    });
  }

  void _handleDelete(MenuItem item, bool isNewItem) {
    final userId = authService.currentUserId;
    if (userId == null) return;

    if (isNewItem) {
      // just remove from local list
      setState(() {
        _menuItems.remove(item);
        _isAddingNew = false;
      });
    } else {
      // call delete API
      menuService
          .deleteMenuItem(userId, item.name)
          .then((_) => _loadMenuItems());
    }
  }

  void _handleSave(MenuItem item, bool isNewItem) {
    if (isNewItem) {
      menuService.insertMenuItem(item).then((_) => _loadMenuItems());
    } else {
      menuService.updateMenuItem(item).then((_) => _loadMenuItems());
    }
    setState(() {
      _isAddingNew = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Menu',
      subtitle: 'Manage your product offerings and updates',
      scrollable: true,
      child: Column(
        children: [
          const SizedBox(height: 16),

          for (final item in _menuItems)
            MenuItemForm(
              key: ValueKey(_menuItems.indexOf(item)),
              menuItem: item,
              isNewItem: _isAddingNew && item.name.isEmpty,
              onSave: _handleSave,
              onDelete: _handleDelete,
              disableActions: _isAddingNew && item.name.isNotEmpty,
            ),

          const SizedBox(height: 12),

          if (!_isAddingNew)
            AppFormButton(
              label: 'Add Menu Item',
              onPressed: _addNewForm,
              icon: const Icon(Icons.add),
            ),
        ],
      ),
    );
  }
}
