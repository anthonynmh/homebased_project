import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:homebased_project/mvp2/activity_feed/activity_feed_data/profile_data.dart' as profile_data;

import 'package:homebased_project/data/notifiers.dart';
import 'package:homebased_project/backend/auth_api/auth_service.dart';
import 'package:homebased_project/mvp2/auth/auth_pages/auth_page.dart';
import 'package:homebased_project/mvp2/profile/profile_data/profile_model.dart';
import 'package:homebased_project/mvp2/profile/profile_data/profile_service.dart';
import 'package:homebased_project/mvp2/profile/profile_pages/profile_popup.dart';
import 'package:homebased_project/mvp2/profile/profile_components/profile_avatar.dart';
import 'package:homebased_project/mvp2/profile/profile_components/profile_mode_container.dart';

class ProfileAppBarSection extends StatefulWidget
    implements PreferredSizeWidget {
  const ProfileAppBarSection({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<ProfileAppBarSection> createState() => _ProfileAppBarSectionState();
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
    Profile? profile = await profileService.getCurrentUserProfile(userId);

    if (profile == null) {
      final newProfile = Profile(
        id: userId,
        email: authService.currentUser?.email,
        username: 'Guest',
        avatarUrl: null,
        fullName: null,
      );
      await profileService.insertCurrentUserProfile(newProfile);
      profile = newProfile;
    }

    profile_data.username = profile.username ?? 'Guest';
    profile_data.fullName = (profile.fullName != null && profile.fullName!.isNotEmpty)
        ? profile.fullName
        : null;
    profile_data.profileImagePath = profile.avatarUrl;

    String? signedUrl;
    if (profile.avatarUrl != null) {
      signedUrl = await profileService.getAvatarUrl(userId);
    }

    if (!mounted) return;
    setState(() {
      username = profile!.username ?? "Guest";
      profileImageUrl = signedUrl;
      loading = false;
    });
  }

  void _switchProfileMode() {
    userMode.value = (userMode.value == 'Seller') ? 'User' : 'Seller';
    setUserMode(userMode.value);
  }

  void _logout() async {
    await authService.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthPage()),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    final userId = authService.currentUserId!;

    await profileService.uploadAvatar(file, userId);
    final url = await profileService.getAvatarUrl(userId);

    if (!mounted) return;
    setState(() => profileImageUrl = url);
  }

  Future<void> _openTelegram() async {
    final url = Uri.parse('https://t.me/food_n_friends');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  Future<void> _onUpdateUsername(String newName) async {
    final userId = authService.currentUserId!;
    await profileService.updateCurrentUserProfile(
      userId: userId,
      username: newName,
    );

    if (!mounted) return;
    setState(() => username = newName);
  }

  void _showProfileDialog(BuildContext context, String mode) {
    showDialog(
      context: context,
      builder: (_) => ProfilePopup(
        username: username,
        profileMode: mode,
        profileImageUrl: profileImageUrl ?? '',
        onSwitchMode: _switchProfileMode,
        onLogout: _logout,
        onChangeAvatar: _pickImage,
        openTelegram: _openTelegram,
        onUpdateUsername: _onUpdateUsername,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: userMode,
      builder: (_, mode, _) {
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
                ProfileModeContainer(mode: mode),
                const SizedBox(width: 12),
                Container(height: 24, width: 1, color: Colors.grey.shade400),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _showProfileDialog(context, mode),
                  child: ProfileAvatar(
                    radius: 20,
                    profileImageUrl: profileImageUrl ?? '',
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ],
        );
      },
    );
  }
}
