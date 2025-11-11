import 'package:flutter/material.dart';

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const Divider(thickness: 1, color: Color(0xFFE8F4F8)),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: const Text(
            "or continue with",
            style: TextStyle(color: Color(0xFFA8B8C8), fontSize: 12),
          ),
        ),
      ],
    );
  }
}
