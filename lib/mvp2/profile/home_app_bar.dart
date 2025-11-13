import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String username;
  final ImageProvider profileImage;
  final String profileMode;
  final VoidCallback onSwitchMode;
  final VoidCallback onLogout;

  const HomeAppBar({
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
      builder: (context) => AlertDialog(
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
            ElevatedButton.icon(
              onPressed: () {
                onSwitchMode();
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.sync),
              label: const Text("Switch Profile Mode"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB885),
                foregroundColor: Colors.white,
              ),
            ),
            const Divider(height: 32),
            ListTile(
              leading: const Icon(Icons.campaign, color: Colors.blue),
              title: const Text('Stay Updated'),
              subtitle: const Text('Join our Telegram channel'),
              onTap: _openTelegram,
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
