import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Color(0xFFC8E8F8), Color(0xFFE8E0F8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: const [
          Icon(Icons.local_cafe, size: 56, color: Color(0xFFFFB885)),
          SizedBox(height: 12),
          Text(
            "Food 'n Friends",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2A4A5A),
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Community in Selling",
            style: TextStyle(fontSize: 12, color: Color(0xFF5A7A8A)),
          ),
        ],
      ),
    );
  }
}
