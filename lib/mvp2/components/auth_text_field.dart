import 'package:flutter/material.dart';

// utils
import 'package:homebased_project/mvp2/utils/field_status.dart';
import 'package:homebased_project/mvp2/utils/border_color.dart';

class AuthTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final FieldStatus status;
  final bool obscure;
  final VoidCallback onComplete;
  final ValueChanged<String> onChanged;
  final String? errorText;

  const AuthTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    required this.status,
    this.obscure = false,
    required this.onComplete,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF5A7A8A), fontSize: 12),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: "Enter your $label".toLowerCase(),
            hintStyle: const TextStyle(fontSize: 14),
            prefixIcon: Icon(icon, size: 20),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: getBorderColor(status), width: 2),
            ),
          ),
          onChanged: onChanged,
          onEditingComplete: onComplete,
        ),
        if (status == FieldStatus.error && errorText != null)
          Text(
            errorText!,
            style: const TextStyle(color: Colors.red, fontSize: 10),
          ),
        const SizedBox(height: 12),
      ],
    );
  }
}
