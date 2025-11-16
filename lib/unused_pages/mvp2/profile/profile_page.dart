import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:homebased_project/data/notifiers.dart';
import 'package:homebased_project/backend/auth_api/auth_service.dart';
import 'package:homebased_project/backend/user_profile_api/user_profile_model.dart';
import 'package:homebased_project/backend/user_profile_api/user_profile_service.dart';
import 'package:homebased_project/backend/business_profile_api/business_profile_model.dart';
import 'package:homebased_project/views/business_profile_tree.dart';

enum UserMode { seller, user }

class ProfilePage extends StatefulWidget {
  final bool hasStorefront;

  const ProfilePage({super.key, this.hasStorefront = false});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserMode userMode = UserMode.seller;

  String? username;
  String? profileImagePath;
  String? tempProfileImagePath;
  XFile? tempProfileImage;
  TextEditingController? usernameController;

  BusinessProfile? businessProfile;
  BusinessProfile? editingBusinessProfile;

  Map<String, String> businessInfo = {
    "businessName": "My Business",
    "description": "Tell us about your business...",
    "location": "",
    "website": "",
    "email": "",
    "phone": "",
  };

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _loadBusinessProfile();
  }

  Future<void> _loadBusinessProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString('businessProfile');

    if (profileJson != null) {
      final profile = BusinessProfile.fromJson(profileJson);
      setState(() {
        businessProfile = profile;
      });
    } else {
      // optionally check Supabase for latest if missing locally
      debugPrint("No business profile found in SharedPreferences.");
    }
  }

  void _defaultToggle() {
    setState(() {
      userMode = userMode == UserMode.seller ? UserMode.user : UserMode.seller;
    });
    setUserMode(userMode == UserMode.seller ? "seller" : "user");
  }

  void handleInputChange(String field, String value) {
    setState(() {
      businessInfo[field] = value;
    });
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

  Widget _buildBusinessProfileCard() {
    final p = businessProfile!;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              p.businessName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (p.description != null && p.description!.isNotEmpty)
              Text(
                p.description!,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            const SizedBox(height: 12),
            if (p.photoUrls != null && p.photoUrls!.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: p.photoUrls!.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      p.photoUrls![i],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => BusinessProfileTree()),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                backgroundColor: const Color(0xfffeb885),
                foregroundColor: Colors.white,
              ),
              child: const Text("Edit Profile"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff9fbfd),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              border: const Border(
                bottom: BorderSide(color: Color(0xffd8e7f5)),
              ),
            ),
            child: SafeArea(
              child: Text(
                username ?? "guest",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: 130,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xffd8e7f5),
                          Color(0xffc9dff0),
                          Color(0xfffeb885),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),

                  // Avatar section
                  Transform.translate(
                    offset: const Offset(0, -60),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.white,
                            backgroundImage: tempProfileImagePath != null
                                ? NetworkImage(tempProfileImagePath!)
                                : (profileImagePath != null &&
                                      profileImagePath!.startsWith('http'))
                                ? NetworkImage(profileImagePath!)
                                : const AssetImage('assets/defaultUser.png'),
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 4, right: 4),
                            child: MouseRegion(
                              cursor: SystemMouseCursors
                                  .click, // changes cursor on web/desktop
                              child: GestureDetector(
                                onTap: _pickProfileImage,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xfffeb885),
                                        Color(0xffffa366),
                                      ],
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Cards section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Mode toggle card
                        _buildModeCard(),

                        if (userMode == UserMode.seller &&
                            businessProfile == null)
                          _buildStorefrontPrompt(),

                        if (userMode == UserMode.seller &&
                            businessProfile != null)
                          _buildBusinessProfileCard(),

                        // Stats
                        // _buildStatsCard(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard() {
    bool isOwner = userMode == UserMode.seller;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 1,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: isOwner
                          ? [const Color(0xfffeb885), const Color(0xffffa366)]
                          : [const Color(0xffd8e7f5), const Color(0xffc9dff0)],
                    ),
                  ),
                  child: Icon(
                    isOwner ? Icons.storefront : Icons.person,
                    color: isOwner ? Colors.white : const Color(0xff5a8fb8),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOwner ? "Owner Mode" : "User Mode",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      isOwner ? "Manage your business" : "Browse and order",
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            OutlinedButton(
              onPressed: _defaultToggle,
              style: OutlinedButton.styleFrom(
                shape: const StadiumBorder(),
                side: const BorderSide(color: Color(0xffd8e7f5)),
              ),
              child: const Text("Switch"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorefrontPrompt() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xfffeb885), width: 2),
      ),
      elevation: 3,
      color: const Color(0xfffff8f3),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xfffeb885), Color(0xffffa366)],
                ),
              ),
              child: const Icon(
                Icons.storefront,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Create Your Storefront",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text(
              "Start your business journey by setting up your storefront profile",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BusinessProfileTree(),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_right_alt),
              label: const Text("Get Started"),
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                backgroundColor: const Color(0xfffeb885),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildStatsCard() {
  //   bool isOwner = userMode == UserMode.seller;
  //   return Card(
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
  //     child: Padding(
  //       padding: const EdgeInsets.all(16),
  //       child: Column(
  //         children: [
  //           const Align(
  //             alignment: Alignment.centerLeft,
  //             child: Text(
  //               "Activity",
  //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
  //             ),
  //           ),
  //           const SizedBox(height: 12),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceAround,
  //             children: [
  //               if (isOwner) _statItem("127", "Posts", const Color(0xffd97a3d)),
  //               _statItem("1.2K", "Followers", const Color(0xff5a8fb8)),
  //               _statItem("842", "Following", const Color(0xffd97a3d)),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _statItem(String value, String label, Color color) {
  //   return Column(
  //     children: [
  //       Text(value, style: TextStyle(fontSize: 20, color: color)),
  //       Text(label, style: const TextStyle(color: Colors.grey)),
  //     ],
  //   );
  // }

  Future<void> _openMaps() async {
    final loc = businessInfo["location"] ?? "";
    final uri = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$loc",
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
