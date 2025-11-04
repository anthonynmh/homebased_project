import 'package:flutter/material.dart';

class CustomMarkerIcon extends StatelessWidget {
  final String logoPath;
  final double size;
  final Color accentColor;

  const CustomMarkerIcon({
    super.key,
    required this.logoPath,
    this.size = 50,
    this.accentColor = const Color(0xFFFF7949),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Circular logo container
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: accentColor, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(child: Image.asset(logoPath, fit: BoxFit.cover)),
        ),

        // Small connecting line
        Container(width: 2, height: 14, color: accentColor),

        // Small circle at bottom
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
        ),
      ],
    );
  }
}
