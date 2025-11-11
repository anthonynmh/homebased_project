import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GoogleButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const GoogleButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFFE8F4F8), width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        minimumSize: const Size.fromHeight(44),
      ),
      icon: SizedBox(
        width: 20,
        height: 20,
        child: SvgPicture.network(
          "https://upload.wikimedia.org/wikipedia/commons/3/3c/Google_Favicon_2025.svg",
          fit: BoxFit.contain,
        ),
      ),
      label: const Text("Google", style: TextStyle(fontSize: 14)),
    );
  }
}
