import 'package:flutter/material.dart';
import 'package:homebased_project/mvp2/app_components/app_card.dart';
import 'package:homebased_project/mvp2/app_components/app_text_field.dart';
import 'package:homebased_project/mvp2/menu/menu_data/menu_item_model.dart';

class MenuItemForm extends StatefulWidget {
  final MenuItem menuItem;
  final VoidCallback onRemove;
  final ValueChanged<MenuItem> onChanged;

  const MenuItemForm({
    super.key,
    required this.menuItem,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  State<MenuItemForm> createState() => _MenuItemFormState();
}

class _MenuItemFormState extends State<MenuItemForm> {
  late final TextEditingController nameController;
  late final TextEditingController descController;
  late final TextEditingController quantityController;
  late final TextEditingController priceController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.menuItem.name);
    descController = TextEditingController(text: widget.menuItem.description);
    quantityController = TextEditingController(
      text: widget.menuItem.quantity.toString(),
    );
    priceController = TextEditingController(
      text: widget.menuItem.price.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    quantityController.dispose();
    priceController.dispose();
    super.dispose();
  }

  void _submitChanges() {
    final updatedItem = MenuItem(
      name: nameController.text,
      description: descController.text,
      quantity: int.tryParse(quantityController.text) ?? 0,
      price: double.tryParse(priceController.text) ?? 0.0,
    );

    widget.onChanged(updatedItem);
  }

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
                  'Menu Item',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                IconButton(
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.close, color: Colors.red),
                ),
              ],
            ),
            AppTextField(
              label: 'Name',
              controller: nameController,
              onChanged: (_) => _submitChanges(),
            ),
            AppTextField(
              label: 'Description',
              controller: descController,
              onChanged: (_) => _submitChanges(),
            ),
            AppTextField(
              label: 'Quantity',
              controller: quantityController,
              onChanged: (_) => _submitChanges(),
            ),
            AppTextField(
              label: 'Price',
              controller: priceController,
              onChanged: (_) => _submitChanges(),
            ),
          ],
        ),
      ),
    );
  }
}
