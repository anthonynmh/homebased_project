import 'package:flutter/material.dart';
import 'package:homebased_project/mvp2/app_components/app_form_button.dart';
import 'package:homebased_project/mvp2/app_components/app_page.dart';
import 'package:homebased_project/mvp2/menu/menu_components/menu_item_form.dart';
import 'package:homebased_project/mvp2/menu/menu_data/menu_item_model.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final List<MenuItem> _menuItems = [];

  void _addMenuItem() {
    setState(() {
      _menuItems.add(
        MenuItem(name: '', description: '', quantity: 0, price: 0.0),
      );
    });
  }

  void _removeMenuItem(int index) {
    setState(() {
      _menuItems.removeAt(index);
    });
  }

  void _updateMenuItem(int index, MenuItem updatedItem) {
    setState(() {
      _menuItems[index] = updatedItem;
    });
  }

  void _broadcastMenu() {
    // Feature not ready
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Broadcast coming soon")));
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Menu',
      subtitle: 'Manage your product offerings and updates',
      scrollable: true,
      action: AppFormButton(
        label: 'Broadcast',
        onPressed: _broadcastMenu,
        icon: const Icon(Icons.speaker_phone),
      ),
      child: Column(
        children: [
          // dynamically render all menu item forms
          ..._menuItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return MenuItemForm(
              menuItem: item,
              onRemove: () => _removeMenuItem(index),
              onChanged: (updatedItem) => _updateMenuItem(index, updatedItem),
            );
          }),
          const SizedBox(height: 16),
          AppFormButton(
            label: 'Add Menu Item',
            onPressed: _addMenuItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
