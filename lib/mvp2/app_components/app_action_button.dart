import 'package:flutter/material.dart';

class AppActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isDestructive;

  const AppActionButton({
    required this.icon,
    required this.label,
    this.onPressed,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: isDestructive ? Colors.red : Color(0xFFFFB885),
        foregroundColor: Colors.white,
      ),
      icon: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onPressed,
    );
  }
}
