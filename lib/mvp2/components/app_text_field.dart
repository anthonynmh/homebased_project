import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final bool obscure;
  final bool readOnly;
  final VoidCallback? onComplete;
  final ValueChanged<String>? onChanged;
  final String? hintText;
  final String? errorText;
  final InputDecoration Function(InputDecoration)? decorationBuilder;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.icon,
    this.obscure = false,
    this.readOnly = false,
    this.onComplete,
    this.onChanged,
    this.hintText,
    this.errorText,
    this.decorationBuilder,
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
            hintText: (hintText ?? "Enter $label").toLowerCase(),
            hintStyle: const TextStyle(fontSize: 14),
            prefixIcon: icon != null ? Icon(icon, size: 20) : null,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onChanged: onChanged,
          onEditingComplete: onComplete,
          readOnly: readOnly,
        ),
        if (errorText != null)
          Text(
            errorText!,
            style: const TextStyle(color: Colors.red, fontSize: 10),
          ),
        const SizedBox(height: 12),
      ],
    );
  }
}
