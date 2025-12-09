import 'package:flutter/material.dart';

import 'package:homebased_project/mvp2/profile/profile_components/profile_header.dart';
import 'package:homebased_project/mvp2/profile/profile_components/profile_actions_section.dart';

class ProfilePopup extends StatefulWidget {
  final String username;
  final String profileImageUrl;
  final String profileMode;

  final VoidCallback onSwitchMode;
  final VoidCallback onLogout;
  final VoidCallback onChangeAvatar;
  final VoidCallback openTelegram;

  final Future<void> Function(String newName) onUpdateUsername;

  const ProfilePopup({
    super.key,
    required this.username,
    required this.profileImageUrl,
    required this.profileMode,
    required this.onSwitchMode,
    required this.onLogout,
    required this.onChangeAvatar,
    required this.openTelegram,
    required this.onUpdateUsername,
  });

  @override
  State<ProfilePopup> createState() => _ProfilePopupState();
}

class _ProfilePopupState extends State<ProfilePopup> {
  bool isEditing = false;
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.username);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _toggleEdit() async {
    if (isEditing) {
      await widget.onUpdateUsername(nameController.text.trim());
    }
    setState(() => isEditing = !isEditing);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: ProfileHeader(
        profileImageUrl: widget.profileImageUrl,
        profileMode: widget.profileMode,
        nameController: nameController,
        isEditing: isEditing,
        onToggleEdit: _toggleEdit,
        onChangeAvatar: widget.onChangeAvatar,
      ),
      content: ProfileActionsSection(
        onSwitchMode: widget.onSwitchMode,
        openTelegram: widget.openTelegram,
        onLogout: widget.onLogout,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
