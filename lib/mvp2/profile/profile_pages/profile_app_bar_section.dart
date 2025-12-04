import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:homebased_project/backend/auth_api/auth_service.dart';
import 'package:homebased_project/backend/user_profile_api/user_profile_model.dart';
import 'package:homebased_project/backend/user_profile_api/user_profile_service.dart';
import 'package:homebased_project/mvp2/profile/profile_components/profile_popup.dart';

class ProfileAppBarSection extends StatefulWidget
    implements PreferredSizeWidget {
  final String profileMode;
  final VoidCallback onSwitchMode;
  final VoidCallback onLogout;

  const ProfileAppBarSection({
    super.key,
    required this.profileMode,
    required this.onSwitchMode,
    required this.onLogout,
  });

  @override
  State<ProfileAppBarSection> createState() => _ProfileAppBarSectionState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _ProfileAppBarSectionState extends State<ProfileAppBarSection> {
  String username = "Guest";
  String? profileImageUrl;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userId = authService.currentUserId!;
    UserProfile? profile = await userProfileService.getCurrentUserProfile(
      userId,
    );

    if (profile == null) {
      final newProfile = UserProfile(
        id: userId,
        email: authService.currentUser?.email,
        username: 'Guest',
        avatarUrl: null,
        fullName: null,
      );
      await userProfileService.insertCurrentUserProfile(newProfile);
      profile = newProfile;
    }

    String? signedUrl;
    if (profile.avatarUrl != null) {
      signedUrl = await userProfileService.getAvatarUrl(userId);
    }

    if (!mounted) return;
    setState(() {
      username = profile!.username ?? "Guest";
      profileImageUrl = signedUrl;
      loading = false;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);

    if (file == null) return;

    final userId = authService.currentUserId!;

    await userProfileService.uploadAvatar(file, userId);

    final url = await userProfileService.getAvatarUrl(userId);

    if (!mounted) return;
    setState(() {
      profileImageUrl = url;
    });
  }

  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ProfilePopup(
        username: username,
        profileMode: widget.profileMode,
        profileImage: profileImageUrl == null
            ? const AssetImage('assets/defaultUser.png')
            : NetworkImage(profileImageUrl!),
        onSwitchMode: widget.onSwitchMode,
        onLogout: widget.onLogout,
        onChangeAvatar: _pickImage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = profileImageUrl == null
        ? const AssetImage("assets/defaultUser.png")
        : NetworkImage(profileImageUrl!) as ImageProvider;

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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB885).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.black54),
                  const SizedBox(width: 4),
                  Text(
                    widget.profileMode,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),
            Container(height: 24, width: 1, color: Colors.grey.shade400),
            const SizedBox(width: 12),

            GestureDetector(
              onTap: () => _showProfileDialog(context),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFFFB885),
                backgroundImage: imageProvider,
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ],
    );
  }
}
