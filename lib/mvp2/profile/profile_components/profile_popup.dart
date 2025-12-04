import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:homebased_project/mvp2/app_components/app_form_button.dart';
import 'package:homebased_project/mvp2/profile/profile_components/profile_option_tile.dart';
import 'package:homebased_project/mvp2/profile/profile_components/profile_avatar.dart';

class ProfilePopup extends StatelessWidget {
  final String username;
  final String profileImageUrl;
  final String profileMode;
  final VoidCallback onSwitchMode;
  final VoidCallback onLogout;
  final VoidCallback onChangeAvatar;

  const ProfilePopup({
    super.key,
    required this.username,
    required this.profileImageUrl,
    required this.profileMode,
    required this.onSwitchMode,
    required this.onLogout,
    required this.onChangeAvatar,
  });

  Future<void> _openTelegram() async {
    final url = Uri.parse('https://t.me/food_n_friends');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
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
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Profile Mode: $profileMode',
                  style: const TextStyle(fontSize: 14, color: Colors.blueGrey),
                ),
              ],
            ),
          ),
        ],
      ),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppFormButton(
            label: "Switch Profile Mode",
            onPressed: () {
              onSwitchMode();
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.sync),
          ),
          const Divider(height: 32),
          ProfileOptionTile(
            icon: Icons.campaign,
            iconColor: Colors.blue,
            title: 'Stay Updated',
            subtitle: 'Join our Telegram channel',
            onTap: _openTelegram,
          ),
          const Divider(),
          ProfileOptionTile(
            icon: Icons.logout,
            iconColor: Colors.red,
            title: 'Logout',
            subtitle: '',
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
