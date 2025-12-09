import 'package:flutter/material.dart';
import 'package:homebased_project/backend/auth_api/auth_service.dart';
import 'package:homebased_project/mvp2/menu/menu_data/menu_item_model.dart';
import 'package:homebased_project/mvp2/menu/menu_components/menu_item_form.dart';

class MenuItemForm extends StatefulWidget {
  final MenuItem menuItem;
  final bool isNewItem;
  final Function(MenuItem, bool) onSave;
  final Function(MenuItem, bool) onDelete;
  final bool disableActions;

  const MenuItemForm({
    super.key,
    required this.menuItem,
    required this.isNewItem,
    required this.onSave,
    required this.onDelete,
    this.disableActions = false,
  });

  @override
  State<MenuItemForm> createState() => _MenuItemFormState();
}

class _MenuItemFormState extends State<MenuItemForm> {
  late MenuItem _item;
  late bool _isEditing;

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _item = widget.menuItem;
    _isEditing = widget.isNewItem;

    _nameController.text = _item.name;
    _descController.text = _item.description ?? "";
    _quantityController.text = _item.quantity.toString();
    _priceController.text = _item.price.toString();
  }

  void _save() {
    final userId = authService.currentUserId;
    if (userId == null) return;

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
      return;
    }

    final updated = MenuItem(
      userId: userId,
      createdAt: _item.createdAt,
      updatedAt: DateTime.now().toIso8601String(),
      name: name,
      description: _descController.text.trim(),
      quantity: quantity,
      price: price,
    );

    widget.onSave(updated, widget.isNewItem);

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
      isEditing: _isEditing,
      isNewItem: widget.isNewItem,
      onSave: _save,
      onDelete: () => widget.onDelete(_item, widget.isNewItem),
      onCancel: () {
        if (widget.isNewItem) {
          widget.onDelete(_item, true);
        } else {
          setState(() {
            _nameController.text = _item.name;
            _descController.text = _item.description ?? "";
            _quantityController.text = _item.quantity.toString();
            _priceController.text = _item.price.toString();
            _isEditing = false;
          });
        }
      },
      onEditToggle: () {
        if (!widget.disableActions) {
          setState(() => _isEditing = true);
        }
      },
    );
  }
}
