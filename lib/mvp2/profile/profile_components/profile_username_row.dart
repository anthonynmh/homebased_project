import 'package:flutter/material.dart';

import 'package:homebased_project/mvp2/app_components/app_text_field.dart';

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
              ? AppTextField(label: 'Username', controller: controller)
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
