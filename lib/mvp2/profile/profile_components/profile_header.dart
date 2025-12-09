import 'package:flutter/material.dart';

import 'package:homebased_project/mvp2/profile/profile_components/profile_avatar.dart';
import 'package:homebased_project/mvp2/profile/profile_components/profile_username_row.dart';

class ProfileHeader extends StatelessWidget {
  final String profileImageUrl;
  final String profileMode;

  final TextEditingController nameController;
  final bool isEditing;

  final VoidCallback onToggleEdit;
  final VoidCallback onChangeAvatar;

  const ProfileHeader({
    super.key,
    required this.profileImageUrl,
    required this.profileMode,
    required this.nameController,
    required this.isEditing,
    required this.onToggleEdit,
    required this.onChangeAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            onChangeAvatar();
            Navigator.pop(context);
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              ProfileAvatar(radius: 32, profileImageUrl: profileImageUrl),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UsernameRow(
                controller: nameController,
                isEditing: isEditing,
                onToggleEdit: onToggleEdit,
              ),
              Text(
                'Profile Mode: $profileMode',
                style: const TextStyle(fontSize: 14, color: Colors.blueGrey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
