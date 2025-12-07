import 'package:flutter/material.dart';
import 'package:homebased_project/backend/auth_api/auth_service.dart';
import 'package:homebased_project/mvp2/menu/menu_data/menu_item_model.dart';
import 'package:homebased_project/mvp2/menu/menu_components/menu_item_form.dart';

class MenuItemForm extends StatefulWidget {
  final MenuItem? menuItem;
  final Function(MenuItem) onSave;
  final VoidCallback onDelete;

  const MenuItemForm({
    super.key,
    required this.menuItem,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<MenuItemForm> createState() => _MenuItemFormState();
}

class _MenuItemFormState extends State<MenuItemForm> {
  late MenuItem? _item;
  late bool _isEditing;

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _item = widget.menuItem;
    _isEditing = widget.menuItem == null || widget.menuItem!.id.isEmpty;
    _nameController.text = _item?.name ?? "";
    _descController.text = _item?.description ?? "";
    _quantityController.text = _item?.quantity.toString() ?? "0";
    _priceController.text = _item?.price.toString() ?? "0.0";
  }

  Future<void> _save() async {
    final userId = authService.currentUserId;
    if (userId == null) return;

    // --- VALIDATION ---
    final quantity = int.tryParse(_quantityController.text);
    final price = double.tryParse(_priceController.text);
    final name = _nameController.text.trim();

    if (quantity == null || price == null || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Quantity and Price must be valid numbers. Name cannot be empty.",
          ),
        ),
      );
      return; // stop save
    }

    final updated = MenuItem(
      id: _item?.id ?? "",
      userId: userId,
      createdAt: _item?.createdAt ?? DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      quantity: quantity,
      price: price,
    );

    widget.onSave(updated);
    setState(() {
      _item = updated;
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MenuItemFormComponent(
      nameController: _nameController,
      descController: _descController,
      quantityController: _quantityController,
      priceController: _priceController,
      onEditToggle: () => setState(() {
        _isEditing = true;
      }),
      isEditing: _isEditing,
      onSave: _save,
      onDelete: widget.onDelete,
      onCancel: () {
        if (_item == null) {
          widget.onDelete(); // cancel new item
        } else {
          setState(() {
            _nameController.text = _item?.name ?? "";
            _descController.text = _item?.description ?? "";
            _quantityController.text = _item?.quantity.toString() ?? "0";
            _priceController.text = _item?.price.toString() ?? "0.0";
            _isEditing = false;
          });
        }
      },
    );
  }
}
