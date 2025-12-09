import 'package:flutter/material.dart';

class UsernameRow extends StatelessWidget {
  final TextEditingController controller;
  final bool isEditing;
  final VoidCallback onToggleEdit;

  const UsernameRow({
    super.key,
    required this.controller,
    required this.isEditing,
    required this.onToggleEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: isEditing
              ? TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: UnderlineInputBorder(),
                  ),
                )
              : Text(
                  controller.text,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: onToggleEdit,
          child: Icon(
            isEditing ? Icons.check : Icons.edit,
            size: 18,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
