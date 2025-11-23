import 'package:flutter/material.dart';

class TogglingTab extends StatelessWidget {
  final String text;
  final bool active;
  final VoidCallback onTap;

  const TogglingTab({
    super.key,
    required this.text,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: active
                ? const [BoxShadow(color: Colors.black12, blurRadius: 4)]
                : null,
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: active
                    ? const Color(0xFF2A4A5A)
                    : const Color(0xFF8A9AAA),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
