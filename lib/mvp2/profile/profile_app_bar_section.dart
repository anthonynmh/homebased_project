import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:homebased_project/mvp2/profile/profile_components/profile_popup.dart';

class ProfileAppBarSection extends StatelessWidget
    implements PreferredSizeWidget {
  final String username;
  final ImageProvider profileImage;
  final String profileMode;
  final VoidCallback onSwitchMode;
  final VoidCallback onLogout;

  const ProfileAppBarSection({
    super.key,
    required this.username,
    required this.profileImage,
    required this.profileMode,
    required this.onSwitchMode,
    required this.onLogout,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  Future<void> _openTelegram() async {
    final url = Uri.parse('https://t.me/food_n_friends');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ProfilePopup(
        username: username,
        profileImage: profileImage,
        profileMode: profileMode,
        onSwitchMode: onSwitchMode,
        onLogout: onLogout,
        onOpenTelegram: _openTelegram,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      title: const Text(
        'Food \'n Friends',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      actions: [
        Row(
          children: [
            // Display-only profile mode
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB885).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.black54),
                  const SizedBox(width: 4),
                  Text(
                    profileMode,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            const SizedBox(width: 12),
            Container(height: 24, width: 1, color: Colors.grey.shade400),
            const SizedBox(width: 12),

            // Avatar (tap opens dialog)
            GestureDetector(
              onTap: () => _showProfileDialog(context),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFFFB885),
                backgroundImage: profileImage,
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ],
    );
  }
}
