import 'package:flutter/material.dart';
import 'package:homebased_project/mvp2/utils/field_status.dart';
import 'package:homebased_project/mvp2/utils/border_color.dart';

// components
import 'package:homebased_project/mvp2/app_components/app_text_field.dart';

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
    return AppTextField(
      label: label,
      controller: controller,
      icon: icon,
      obscure: obscure,
      onComplete: onComplete,
      onChanged: onChanged,
      errorText: status == FieldStatus.error ? errorText : null,
      hintText: "Enter your $label".toLowerCase(),
      decorationBuilder: (base) {
        return base.copyWith(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: getBorderColor(status), width: 2),
          ),
        );
      },
    );
  }
}
