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
    });
  }

  void _addNewForm() {
    _isAddingNew = true;
    final userId = authService.currentUserId;
    if (userId == null) return;
    setState(() {
      _menuItems.add(
        MenuItem(
          id: "", // temporary ID
          userId: userId,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          name: "",
          description: "",
          quantity: 0,
          price: 0.0,
        ),
      );
    });
  }

  void _handleDelete(String id) {
    debugPrint("Deleting item with id: $id");
    setState(() {
      if (id.isEmpty) {
        // if id is empty, it is a new unsaved item
        _menuItems.removeLast();
      } else {
        //call delete api here
        _menuItems.removeWhere((item) => item.id == id);
      }
      _isAddingNew = false;
    });
  }

  void _handleSave(MenuItem item) {
    debugPrint("Saving item: ${item.toJson()}");
    if (item.id.isEmpty) {
      // Call create API
      menuService.insertMenuItem(item).then((_) {
        _loadMenuItems(); //reloads the page after saving
      });
    } else {
      // Call update API
      menuService.updateMenuItem(item).then((_) {
        _loadMenuItems(); //reloads the page after saving
      });
    }
    //reloads the page after saving
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

          // Render existing menu items
          for (final item in _menuItems)
            MenuItemForm(
              key: ValueKey(item.id),
              menuItem: item,
              onSave: _handleSave,
              onDelete: () => _handleDelete(item.id),
            ),

          const SizedBox(height: 12),

          // Add new item button only if user adding is not in progress
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
