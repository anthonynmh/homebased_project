import 'package:flutter/material.dart';

import 'package:homebased_project/v2/models/v2_marketplace.dart';

typedef V2StorefrontFormSubmit =
    void Function({
      required String name,
      required String description,
      required String pickupArea,
    });

typedef V2CatalogItemFormSubmit =
    void Function({
      required String name,
      required String description,
      required double price,
      required String availability,
    });

class V2StorefrontFormSheet extends StatefulWidget {
  final String title;
  final V2Storefront? storefront;
  final V2StorefrontFormSubmit onSubmit;

  const V2StorefrontFormSheet({
    super.key,
    required this.title,
    this.storefront,
    required this.onSubmit,
  });

  @override
  State<V2StorefrontFormSheet> createState() => _V2StorefrontFormSheetState();
}

class _V2StorefrontFormSheetState extends State<V2StorefrontFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _pickupAreaController;

  @override
  void initState() {
    super.initState();
    final storefront = widget.storefront;
    _nameController = TextEditingController(
      text: storefront?.name ?? 'Weekend Kitchen',
    );
    _descriptionController = TextEditingController(
      text:
          storefront?.description ??
          'Small-batch food prepared for nearby pickups.',
    );
    _pickupAreaController = TextEditingController(
      text: storefront?.pickupArea ?? 'Near you',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _pickupAreaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        top: 18,
        bottom: MediaQuery.of(context).viewInsets.bottom + 18,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Storefront name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pickupAreaController,
              decoration: const InputDecoration(
                labelText: 'Pickup area',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              minLines: 3,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.storefront_outlined),
                label: const Text('Save storefront'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a storefront name first.')),
      );
      return;
    }

    widget.onSubmit(
      name: _nameController.text,
      description: _descriptionController.text,
      pickupArea: _pickupAreaController.text,
    );
    Navigator.of(context).pop();
  }
}

class V2CatalogItemFormSheet extends StatefulWidget {
  final String title;
  final V2CatalogItem? item;
  final V2CatalogItemFormSubmit onSubmit;

  const V2CatalogItemFormSheet({
    super.key,
    required this.title,
    this.item,
    required this.onSubmit,
  });

  @override
  State<V2CatalogItemFormSheet> createState() => _V2CatalogItemFormSheetState();
}

class _V2CatalogItemFormSheetState extends State<V2CatalogItemFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late String _availability;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameController = TextEditingController(
      text: item?.name ?? 'New food item',
    );
    _descriptionController = TextEditingController(
      text: item?.description ?? 'A simple food item for the catalog.',
    );
    _priceController = TextEditingController(
      text: item == null ? '12.00' : item.price.toStringAsFixed(2),
    );
    _availability = item?.availability ?? V2Availability.available;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        top: 18,
        bottom: MediaQuery.of(context).viewInsets.bottom + 18,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Food item name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              minLines: 3,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      prefixText: 'S\$ ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _availability,
                    decoration: const InputDecoration(
                      labelText: 'Availability',
                      border: OutlineInputBorder(),
                    ),
                    items: V2Availability.values
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(V2Availability.label(value)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _availability = value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.restaurant_menu_outlined),
                label: const Text('Save food item'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final price = double.tryParse(_priceController.text.trim());
    if (_nameController.text.trim().isEmpty || price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a name and valid price first.')),
      );
      return;
    }

    widget.onSubmit(
      name: _nameController.text,
      description: _descriptionController.text,
      price: price,
      availability: _availability,
    );
    Navigator.of(context).pop();
  }
}
