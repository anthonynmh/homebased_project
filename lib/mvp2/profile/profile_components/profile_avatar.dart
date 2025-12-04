import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final double radius;
  final Color backgroundColor;
  final String profileImageUrl;

  const ProfileAvatar({
    super.key,
    required this.radius,
    this.backgroundColor = const Color(0xFFFFB885),
    this.profileImageUrl = '',
  });

  @override
  Widget build(BuildContext context) {
    final ImageProvider imageProvider = profileImageUrl.isEmpty
        ? const AssetImage("assets/defaultUser.png")
        : NetworkImage(profileImageUrl);

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      backgroundImage: imageProvider,
    );
  }
}
