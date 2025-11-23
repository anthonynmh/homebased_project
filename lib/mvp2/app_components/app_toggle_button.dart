import 'package:flutter/material.dart';

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double size;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Ink(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFFFB885), // SAME brand button color
        shape: BoxShape.circle,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(size / 2),
        onTap: isLoading ? null : onPressed,
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}
