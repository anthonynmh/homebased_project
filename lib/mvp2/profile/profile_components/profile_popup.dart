import 'package:flutter/material.dart';

import 'package:homebased_project/mvp2/app_components/app_form_button.dart';

class ProfilePopup extends StatelessWidget {
  final String username;
  final ImageProvider profileImage;
  final String profileMode;
  final VoidCallback onSwitchMode;
  final VoidCallback onLogout;
  final VoidCallback onOpenTelegram;

  const ProfilePopup({
    super.key,
    required this.username,
    required this.profileImage,
    required this.profileMode,
    required this.onSwitchMode,
    required this.onLogout,
    required this.onOpenTelegram,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFFFB885),
            backgroundImage: profileImage,
          ),
          const SizedBox(width: 12),
          Text(username, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profile Mode: $profileMode'),
          const SizedBox(height: 16),
          AppFormButton(
            label: "Switch Profile Mode",
            onPressed: () {
              onSwitchMode();
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.sync),
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.campaign, color: Colors.blue),
            title: const Text('Stay Updated'),
            subtitle: const Text('Join our Telegram channel'),
            onTap: onOpenTelegram,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              onLogout();
            },
          ),
        ],
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
