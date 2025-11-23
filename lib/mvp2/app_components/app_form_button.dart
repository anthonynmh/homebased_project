import 'package:flutter/material.dart';

class AppFormButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Icon? icon;

  const AppFormButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFFFB885),
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );

    // Loading → ignore icon & text, always show spinner
    if (isLoading) {
      return ElevatedButton(
        style: buttonStyle,
        onPressed: null,
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    // With icon → use ElevatedButton.icon
    if (icon != null) {
      return ElevatedButton.icon(
        style: buttonStyle,
        onPressed: onPressed,
        icon: icon!,
        label: Text(label),
      );
    }

    // No icon → normal ElevatedButton
    return ElevatedButton(
      style: buttonStyle,
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
