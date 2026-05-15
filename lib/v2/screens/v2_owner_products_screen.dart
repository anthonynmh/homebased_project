import 'package:flutter/material.dart';

import 'package:homebased_project/v2/models/v2_marketplace.dart';
import 'package:homebased_project/v2/state/v2_app_controller.dart';
import 'package:homebased_project/v2/widgets/v2_marketplace_forms.dart';
import 'package:homebased_project/v2/widgets/v2_owner_widgets.dart';

class V2OwnerProductsScreen extends StatefulWidget {
  final V2AppController controller;

  const V2OwnerProductsScreen({super.key, required this.controller});

  @override
  State<V2OwnerProductsScreen> createState() => _V2OwnerProductsScreenState();
}

class _V2OwnerProductsScreenState extends State<V2OwnerProductsScreen> {
  String? _selectedStorefrontId;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final storefronts = widget.controller.ownedStorefronts;
        if (_selectedStorefrontId != null &&
            !storefronts.any(
              (storefront) => storefront.id == _selectedStorefrontId,
            )) {
          _selectedStorefrontId = null;
        }
        final selectedStorefront = _selectedStorefrontId == null
            ? null
            : widget.controller.storefrontById(_selectedStorefrontId!);
        final visibleStorefronts = selectedStorefront == null
            ? storefronts
            : [selectedStorefront];
        final live = _productsFor(visibleStorefronts, V2ProductStatus.live);
        final tests = _productsFor(
          visibleStorefronts,
          V2ProductStatus.upcoming,
        );

        return V2OwnerPage(
          children: [
            V2OwnerHeader(
              title: 'Products',
              subtitle:
                  'Manage live products, upcoming drops, and ideas you are testing.',
              action: storefronts.isEmpty
                  ? null
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed: () => _openProductForm(
                            context,
                            selectedStorefront ?? storefronts.first,
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text('Add product'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _openProductForm(
                            context,
                            selectedStorefront ?? storefronts.first,
                            status: V2ProductStatus.upcoming,
                          ),
                          icon: const Icon(Icons.lightbulb_outline),
                          label: const Text('Create interest check'),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            if (storefronts.isEmpty)
              const V2OwnerEmptyState(
                icon: Icons.storefront_outlined,
                title: 'Create a storefront first',
                body:
                    'Add a storefront before you publish products or test demand.',
              )
            else ...[
              V2StorefrontSelector(
                storefronts: storefronts,
                selectedStorefrontId: _selectedStorefrontId,
                onSelected: (storefrontId) {
                  setState(() => _selectedStorefrontId = storefrontId);
                },
              ),
              const SizedBox(height: 16),
              _DemandValidationSection(
                controller: widget.controller,
                products: tests,
                storefronts: visibleStorefronts,
                onCreate: () => _openProductForm(
                  context,
                  selectedStorefront ?? storefronts.first,
                  status: V2ProductStatus.upcoming,
                ),
                onEdit: (product) => _openProductForm(
                  context,
                  widget.controller.storefrontById(product.storefrontId) ??
                      storefronts.first,
                  product: product,
                ),
                onDelete: (product) => _confirmDelete(context, product),
              ),
              const SizedBox(height: 16),
              _LiveProductsSection(
                controller: widget.controller,
                products: live,
                storefronts: visibleStorefronts,
                onCreate: () => _openProductForm(
                  context,
                  selectedStorefront ?? storefronts.first,
                ),
                onEdit: (product) => _openProductForm(
                  context,
                  widget.controller.storefrontById(product.storefrontId) ??
                      storefronts.first,
                  product: product,
                ),
                onDelete: (product) => _confirmDelete(context, product),
              ),
            ],
          ],
        );
      },
    );
  }

  List<V2CatalogItem> _productsFor(
    List<V2Storefront> storefronts,
    String status,
  ) {
    return storefronts
        .expand(
          (storefront) =>
              widget.controller.productsFor(storefront.id, status: status),
        )
        .toList(growable: false);
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
        title: product == null
            ? status == V2ProductStatus.upcoming
                  ? 'Create interest check'
                  : 'Create product'
            : 'Edit product',
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
                widget.controller.addCatalogItem(
                  storefrontId: storefront.id,
                  name: name,
                  description: description,
                  price: price,
                  category: category,
                  status: status,
                  imageUrl: imageUrl,
                );
              } else {
                widget.controller.updateCatalogItem(
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
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB42318),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) widget.controller.deleteCatalogItem(product.id);
  }
}

class _DemandValidationSection extends StatelessWidget {
  final V2AppController controller;
  final List<V2CatalogItem> products;
  final List<V2Storefront> storefronts;
  final VoidCallback onCreate;
  final ValueChanged<V2CatalogItem> onEdit;
  final ValueChanged<V2CatalogItem> onDelete;

  const _DemandValidationSection({
    required this.controller,
    required this.products,
    required this.storefronts,
    required this.onCreate,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return V2OwnerCard(
      color: const Color(0xFFFFF8EF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          V2OwnerSectionHeader(
            title: 'Testing the market',
            subtitle:
                'Use replies, subscribers, and interest signals to decide what to make, restock, or launch next.',
            trailing: IconButton.filledTonal(
              tooltip: 'Create interest check',
              onPressed: onCreate,
              icon: const Icon(Icons.add),
            ),
          ),
          const SizedBox(height: 14),
          if (products.isEmpty)
            V2OwnerEmptyState(
              icon: Icons.lightbulb_outline,
              title: 'Test demand before you commit',
              body:
                  'Post an idea and use customer replies to decide what to launch next.',
              action: FilledButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.lightbulb_outline),
                label: const Text('Create interest check'),
              ),
            )
          else
            _ResponsiveGrid(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _InterestCheckCard(
                  controller: controller,
                  product: product,
                  onEdit: () => onEdit(product),
                  onDelete: () => onDelete(product),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _LiveProductsSection extends StatelessWidget {
  final V2AppController controller;
  final List<V2CatalogItem> products;
  final List<V2Storefront> storefronts;
  final VoidCallback onCreate;
  final ValueChanged<V2CatalogItem> onEdit;
  final ValueChanged<V2CatalogItem> onDelete;

  const _LiveProductsSection({
    required this.controller,
    required this.products,
    required this.storefronts,
    required this.onCreate,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        V2OwnerSectionHeader(
          title: 'Ready to sell',
          subtitle: 'Listings customers can act on now.',
          trailing: TextButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add product'),
          ),
        ),
        const SizedBox(height: 10),
        if (products.isEmpty)
          V2OwnerEmptyState(
            icon: Icons.inventory_2_outlined,
            title: 'No live products yet',
            body: 'Add a product when you are ready to take orders.',
            action: FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Add product'),
            ),
          )
        else
          _ResponsiveGrid(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return _ProductCard(
                controller: controller,
                product: product,
                onEdit: () => onEdit(product),
                onDelete: () => onDelete(product),
              );
            },
          ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final V2AppController controller;
  final V2CatalogItem product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCard({
    required this.controller,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return V2OwnerCard(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: V2ProductImage(imageUrl: product.imageUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: v2OwnerInk,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          height: 1.1,
                        ),
                      ),
                    ),
                    Text(
                      product.priceLabel,
                      style: const TextStyle(
                        color: v2OwnerTeal,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    V2StatusChip(
                      label: controller.storefrontNameFor(product.storefrontId),
                      color: const Color(0xFFEAF3EF),
                      textColor: v2OwnerTeal,
                    ),
                    const V2StatusChip(
                      label: 'Live',
                      icon: Icons.check_circle_outline,
                      color: Color(0xFFECFDF5),
                      textColor: Color(0xFF047857),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF39433E),
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.category,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: v2OwnerMuted,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    IconButton.filledTonal(
                      tooltip: 'Edit product',
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                    ),
                    PopupMenuButton<_ProductAction>(
                      tooltip: 'More product actions',
                      onSelected: (action) {
                        switch (action) {
                          case _ProductAction.delete:
                            onDelete();
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: _ProductAction.delete,
                          child: ListTile(
                            leading: Icon(
                              Icons.delete_outline,
                              color: Color(0xFFB42318),
                            ),
                            title: Text('Delete product'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InterestCheckCard extends StatelessWidget {
  final V2AppController controller;
  final V2CatalogItem product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _InterestCheckCard({
    required this.controller,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final relatedThreads = controller
        .threadsForStorefront(product.storefrontId)
        .where((thread) => thread.relatedLabel == product.name)
        .toList();
    final replies = relatedThreads.fold<int>(
      0,
      (total, thread) => total + controller.commentsForThread(thread.id).length,
    );
    final subscribers = controller.subscriberCountFor(product.storefrontId);
    final signals = replies + subscribers;

    return V2OwnerCard(
      color: const Color(0xFFFFFCF7),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 82,
                child: V2ProductImage(
                  imageUrl: product.imageUrl,
                  icon: Icons.lightbulb_outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const V2StatusChip(
                      label: 'Testing demand',
                      icon: Icons.lightbulb_outline,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: v2OwnerInk,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${controller.storefrontNameFor(product.storefrontId)} · ${product.priceLabel}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: v2OwnerMuted,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            product.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF39433E),
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              V2MetricChip(
                icon: Icons.trending_up,
                label: 'signals',
                value: '$signals',
              ),
              V2MetricChip(
                icon: Icons.chat_bubble_outline,
                label: 'replies',
                value: '$replies',
              ),
              V2MetricChip(
                icon: Icons.people_alt_outlined,
                label: 'subscribers',
                value: '$subscribers',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('Manage check'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Delete interest check',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                color: const Color(0xFFB42318),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResponsiveGrid extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;

  const _ResponsiveGrid({required this.itemCount, required this.itemBuilder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 720;
        final width = twoColumns
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(
            itemCount,
            (index) =>
                SizedBox(width: width, child: itemBuilder(context, index)),
          ),
        );
      },
    );
  }
}

enum _ProductAction { delete }
