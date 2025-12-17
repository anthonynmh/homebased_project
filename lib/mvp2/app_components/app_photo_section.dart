import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AppPhotoSection extends StatelessWidget {
  final ImageProvider? image;
  final XFile? localFile; // 👈 ADD THIS
  final double height;
  final String emptyLabel;

  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AppPhotoSection({
    super.key,
    this.image,
    this.localFile,
    this.height = 180,
    this.emptyLabel = 'Add photo',
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  bool get _hasImage => image != null || localFile != null;

  @override
  Widget build(BuildContext context) {
    debugPrint('PHOTO SECTION → localFile=${localFile?.path}, image=$image');
    return GestureDetector(
      onTap: !_hasImage ? onTap : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: height,
          width: double.infinity,
          color: Colors.grey[100],
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (localFile != null)
                Image.network(localFile!.path, fit: BoxFit.cover)
              else if (image != null)
                Image(image: image!, fit: BoxFit.cover)
              else
                _EmptyState(label: emptyLabel),

              if (_hasImage) _ImageActions(onEdit: onEdit, onDelete: onDelete),
            ],
          ),
        ),
      ),
    );
  }
}

/* ---------- PRIVATE WIDGETS ---------- */

class _EmptyState extends StatelessWidget {
  final String label;

  const _EmptyState({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.image_outlined, size: 40, color: Colors.grey),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _ImageActions extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ImageActions({this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PhotoActionButton(icon: Icons.edit, onPressed: onEdit),
            const SizedBox(width: 8),
            _PhotoActionButton(icon: Icons.delete, onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}

class _PhotoActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _PhotoActionButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}
