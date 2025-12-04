import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:homebased_project/backend/auth_api/auth_service.dart';
import 'package:homebased_project/backend/user_profile_api/user_profile_model.dart';
import 'package:homebased_project/backend/user_profile_api/user_profile_service.dart';
import 'package:homebased_project/data/notifiers.dart';
import 'package:homebased_project/mvp2/main/main_components/main_seller_navbar_widget.dart';
import 'package:homebased_project/mvp2/main/main_components/main_user_navbar_widget.dart';

// MVP2
import 'package:homebased_project/mvp2/auth/auth_pages/auth_page.dart';
import 'package:homebased_project/mvp2/profile/profile_app_bar_section.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  String? username;
  String? profileImagePath;
  String? tempProfileImagePath;
  XFile? tempProfileImage;
  TextEditingController? usernameController;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    debugPrint("➡️ Starting _loadProfileData...");

    UserProfile? userProfile = await userProfileService.getCurrentUserProfile(
      authService.currentUserId!,
    );

    if (userProfile == null) {
      debugPrint("⚠️ No user profile found. Creating default one...");

      final newProfile = UserProfile(
        id: authService.currentUserId!,
        email: authService.currentUser?.email,
        username: 'Guest',
        avatarUrl: null,
        fullName: null,
      );

      try {
        await userProfileService.insertCurrentUserProfile(newProfile);
        debugPrint("✅ Inserted default profile for user: ${newProfile.id}");
        userProfile = newProfile;
      } catch (e, st) {
        debugPrint("❌ Failed to insert default profile: $e\n$st");
        return; // bail out early
      }
    } else {
      debugPrint("✅ Retrieved existing profile for user: ${userProfile.id}");
      debugPrint(
        "   Username: ${userProfile.username}, Avatar: ${userProfile.avatarUrl}",
      );
    }

    // 🔑 Get signed URL
    String? signedUrl;
    if (userProfile.avatarUrl != null) {
      signedUrl = await userProfileService.getAvatarUrl(
        authService.currentUserId!,
      );
    }

    if (!mounted) return;
    setState(() {
      username = userProfile?.username?.isNotEmpty == true
          ? userProfile!.username
          : 'Guest';
      usernameController = TextEditingController(text: username);
      profileImagePath = tempProfileImagePath ?? signedUrl;
    });

    debugPrint("🎯 Finished _loadProfileData. State updated.");
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        tempProfileImage = pickedFile;
        tempProfileImagePath = pickedFile.path;
      });
      debugPrint("🖼️ Picked new profile image: ${pickedFile.path}");
    }

    try {
      debugPrint("🖼️ Uploading avatar...");
      await userProfileService.uploadAvatar(
        tempProfileImage!,
        authService.currentUserId!,
      );

      // Get new signed URL right after upload
      final newSignedUrl = await userProfileService.getAvatarUrl(
        authService.currentUserId!,
      );

      setState(() {
        profileImagePath = newSignedUrl;
        tempProfileImagePath = null; // clear preview
      });

      debugPrint("✅ Avatar uploaded and refreshed successfully.");
    } catch (e, st) {
      debugPrint("❌ Failed to upload avatar: $e\n$st");
    }
  }

  void _switchProfileMode() {
    setState(() {
      userMode.value = userMode.value == 'Seller' ? 'User' : 'Seller';
    });
    setUserMode(userMode.value);
    // Optionally persist this state to backend
  }

  void _logout() async {
    await authService.signOut();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ProfileAppBarSection(
        username: username ?? '',
        profileImage: profileImagePath == null
            ? const AssetImage('assets/defaultUser.png')
            : NetworkImage(profileImagePath!) as ImageProvider,
        profileMode: userMode.value,
        onSwitchMode: _switchProfileMode,
        onLogout: _logout,
      ),
      body: ValueListenableBuilder<String>(
        valueListenable: userMode,
        builder: (context, mode, child) {
          return ValueListenableBuilder<int>(
            valueListenable: selectedPageNotifier,
            builder: (context, selectedIndex, _) {
              final pages = mode == "Seller" ? sellerPages : defaultUserPages;
              return pages.elementAt(selectedIndex);
            },
          );
        },
      ),

      bottomNavigationBar: ValueListenableBuilder<String>(
        valueListenable: userMode,
        builder: (context, mode, child) {
          return mode == "Seller"
              ? const SellerNavbarWidget()
              : const DefaultUserNavbarWidget();
        },
      ),
    );
  }
}
