import 'package:flutter/material.dart';

import 'package:homebased_project/v2/models/v2_marketplace.dart';
import 'package:homebased_project/v2/state/v2_app_controller.dart';
import 'package:homebased_project/v2/widgets/v2_marketplace_forms.dart';

class V2OwnerProductsScreen extends StatelessWidget {
  final V2AppController controller;

  const V2OwnerProductsScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final storefront = controller.ownerStorefront;
        final live = storefront == null
            ? const <V2CatalogItem>[]
            : controller.productsFor(
                storefront.id,
                status: V2ProductStatus.live,
              );
        final upcoming = storefront == null
            ? const <V2CatalogItem>[]
            : controller.productsFor(
                storefront.id,
                status: V2ProductStatus.upcoming,
              );

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Products',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF17201D),
                              ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          storefront == null
                              ? 'Create a storefront first.'
                              : '${live.length} live · ${upcoming.length} upcoming',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: const Color(0xFF647067),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (storefront != null)
                    PopupMenuButton<String>(
                      tooltip: 'Create product',
                      icon: const Icon(Icons.add_circle_outline),
                      onSelected: (status) =>
                          _openProductForm(context, storefront, status: status),
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: V2ProductStatus.live,
                          child: Text('Create product'),
                        ),
                        PopupMenuItem(
                          value: V2ProductStatus.upcoming,
                          child: Text('Create upcoming product'),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (storefront == null)
                const _EmptyPanel(
                  icon: Icons.storefront_outlined,
                  label: 'Switch to My Store to create a storefront first.',
                )
              else ...[
                _ProductSection(
                  title: 'Current products',
                  emptyLabel: 'No live products yet.',
                  products: live,
                  onEdit: (product) =>
                      _openProductForm(context, storefront, product: product),
                  onDelete: (product) => _confirmDelete(context, product),
                ),
                const SizedBox(height: 12),
                _ProductSection(
                  title: 'Upcoming products',
                  emptyLabel: 'No upcoming products yet.',
                  products: upcoming,
                  onEdit: (product) =>
                      _openProductForm(context, storefront, product: product),
                  onDelete: (product) => _confirmDelete(context, product),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _openProductForm(
    BuildContext context,
    V2Storefront storefront, {
    V2CatalogItem? product,
    String status = V2ProductStatus.live,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => V2CatalogItemFormSheet(
        title: product == null ? 'Create product' : 'Edit product',
        item: product,
        initialStatus: status,
        onSubmit:
            ({
              required category,
              required description,
              required imageUrl,
              required name,
              required price,
              required status,
            }) {
              if (product == null) {
                controller.addCatalogItem(
                  storefrontId: storefront.id,
                  name: name,
                  description: description,
                  price: price,
                  category: category,
                  status: status,
                  imageUrl: imageUrl,
                );
              } else {
                controller.updateCatalogItem(
                  itemId: product.id,
                  name: name,
                  description: description,
                  price: price,
                  category: category,
                  status: status,
                  imageUrl: imageUrl,
                );
              }
            },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    V2CatalogItem product,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text('Delete ${product.name} from the local prototype?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) controller.deleteCatalogItem(product.id);
  }
}

class _ProductSection extends StatelessWidget {
  final String title;
  final String emptyLabel;
  final List<V2CatalogItem> products;
  final ValueChanged<V2CatalogItem> onEdit;
  final ValueChanged<V2CatalogItem> onDelete;

  const _ProductSection({
    required this.title,
    required this.emptyLabel,
    required this.products,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            if (products.isEmpty)
              _EmptyStrip(
                icon: Icons.restaurant_menu_outlined,
                label: emptyLabel,
              )
            else
              ...products.map(
                (product) => _ProductTile(
                  product: product,
                  onEdit: () => onEdit(product),
                  onDelete: () => onDelete(product),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final V2CatalogItem product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductTile({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFF6F7F4),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8E2)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                        Text(
                          product.priceLabel,
                          style: const TextStyle(
                            color: Color(0xFF176B87),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.description,
                      style: const TextStyle(
                        color: Color(0xFF647067),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${product.category} · ${product.statusLabel}',
                      style: const TextStyle(
                        color: Color(0xFF39433E),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: 'Edit product',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Delete product',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                color: const Color(0xFFB42318),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _EmptyPanel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF647067)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF39433E),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyStrip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _EmptyStrip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF1D4ED8)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF1D4ED8),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
