import 'package:flutter/material.dart';
import 'package:homebased_project/mvp2/app_components/app_action_button.dart';
import 'package:homebased_project/mvp2/app_components/app_card.dart';
import 'package:homebased_project/mvp2/menu/menu_data/menu_item_model.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final String? photoUrl;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MenuItemCard({
    super.key,
    required this.item,
    this.photoUrl,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint("Photo URL received: $photoUrl");
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PhotoSection(photoUrl: photoUrl),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardContent(item: item),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppActionButton(
                      icon: Icons.edit,
                      label: 'Edit',
                      onPressed: onEdit,
                    ),
                    const SizedBox(width: 12),
                    AppActionButton(
                      icon: Icons.delete,
                      label: 'Delete',
                      onPressed: onDelete,
                      isDestructive: true,
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

class _PhotoSection extends StatelessWidget {
  final String? photoUrl;

  const _PhotoSection({this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Container(
        height: 140,
        width: double.infinity,
        color: Colors.grey[200],
        child: photoUrl != null
            ? Image.network(
                photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(Icons.broken_image),
              )
            : const Center(child: Icon(Icons.image_outlined, size: 40)),
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  final MenuItem item;

  const _CardContent({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          item.description ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text('Quantity: ${item.quantity}'),
        const SizedBox(height: 4),
        Text('Price: \$${item.price?.toStringAsFixed(2) ?? '0.00'}'),
      ],
    );
  }
}
