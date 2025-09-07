import 'dart:io';
import 'package:flutter/material.dart';
import 'package:homebased_project/backend/auth_api/auth_service.dart';
import 'package:homebased_project/backend/user_profile_api/user_profile_model.dart';
import 'package:homebased_project/backend/user_profile_api/user_profile_service.dart';
import 'package:homebased_project/models/business_profile.dart';
import 'package:homebased_project/views/business_profile_tree.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:homebased_project/widgets/form_field_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? username;
  String? profileImagePath;
  String? tempProfileImagePath;
  TextEditingController? usernameController;

  BusinessProfile? businessProfile;
  BusinessProfile? editingBusinessProfile;
  final _formKey = GlobalKey<FormState>();
  final _imagesKey = GlobalKey<CustomFormFieldState>();

  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _loadBusinessProfile();
  }

  Future<void> _loadBusinessProfile() async {
    final profile = await loadBusinessProfile();
    setState(() {
      businessProfile = profile;
    });
  }

  Future<void> saveBusinessProfile(BusinessProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final images = _imagesKey.currentState?.getImages() ?? [];
    final updatedProfile = profile.copyWith(imagePaths: images);
    businessProfile = updatedProfile;
    await prefs.setString('businessProfile', updatedProfile.toJson());
  }

  Future<BusinessProfile?> loadBusinessProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? profileJson = prefs.getString('businessProfile');
    if (profileJson == null) return null;
    return BusinessProfile.fromJson(profileJson);
  }

  Future<void> _loadProfileData() async {
    debugPrint("➡️ Starting _loadProfileData...");

    UserProfile? userProfile = await UserProfileService.getCurrentUserProfile();

    if (userProfile == null) {
      debugPrint("⚠️ No user profile found. Creating default one...");

      final newProfile = UserProfile(
        id: AuthService.currentUserId!,
        email: AuthService.currentUser?.email,
        username: 'Guest',
        avatarUrl: null,
        fullName: null,
      );

      try {
        await UserProfileService.insertCurrentUserProfile(newProfile);
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
    if (userProfile?.avatarUrl != null) {
      signedUrl = await UserProfileService.getAvatarUrl();
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
        tempProfileImagePath = pickedFile.path;
      });
      debugPrint("🖼️ Picked new profile image: ${pickedFile.path}");
    }
  }

  Future<void> _saveAll() async {
    final uname = usernameController?.text ?? '';
    final usernameEmpty = uname.trim().isEmpty;

    bool formValid = true;
    if (businessProfile != null) {
      formValid = _formKey.currentState?.validate() ?? false;
    }

    if (usernameEmpty || !formValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            usernameEmpty
                ? "Username cannot be empty."
                : "Please fill in all required fields.",
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final newUsername = uname.trim();

    try {
      debugPrint("✏️ Updating username to $newUsername...");
      if (newUsername.isNotEmpty) {
        await UserProfileService.updateCurrentUserProfile(
          UserProfile(id: AuthService.currentUserId!, username: newUsername),
        );
      }
      username = newUsername;
      debugPrint("✅ Username updated successfully.");
    } catch (e, st) {
      debugPrint("❌ Failed to update username: $e\n$st");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to update profile. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (tempProfileImagePath != null) {
      try {
        debugPrint("🖼️ Uploading avatar...");
        final file = File(tempProfileImagePath!);
        await UserProfileService.uploadAvatar(file);

        // Get new signed URL right after upload
        final newSignedUrl = await UserProfileService.getAvatarUrl();

        setState(() {
          profileImagePath = newSignedUrl;
          tempProfileImagePath = null; // clear preview
        });

        debugPrint("✅ Avatar uploaded and refreshed successfully.");
      } catch (e, st) {
        debugPrint("❌ Failed to upload avatar: $e\n$st");
      }
    }

    if (businessProfile != null && editingBusinessProfile != null) {
      final images = _imagesKey.currentState?.getImages() ?? [];
      editingBusinessProfile = editingBusinessProfile!.copyWith(
        imagePaths: images,
      );

      businessProfile = editingBusinessProfile;
      await saveBusinessProfile(businessProfile!);
      debugPrint("💾 Business profile saved locally.");
    }

    setState(() {
      isEditing = false;
      editingBusinessProfile = null;
    });

    debugPrint("🎯 _saveAll finished, state updated.");
  }

  void _cancelAll() {
    setState(() {
      tempProfileImagePath = null;
      usernameController?.text = username ?? 'Guest';
      editingBusinessProfile = null;
      isEditing = false;
    });
    debugPrint("❌ Edit cancelled, reverted state.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          isEditing
              ? IconButton(icon: Icon(Icons.cancel), onPressed: _cancelAll)
              : IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    setState(() {
                      editingBusinessProfile = businessProfile?.copyWith();
                      isEditing = true;
                      tempProfileImagePath = null;
                      usernameController = TextEditingController(
                        text: username ?? 'Guest',
                      );
                    });
                  },
                ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.transparent,
                    backgroundImage: tempProfileImagePath != null
                        ? FileImage(File(tempProfileImagePath!))
                        : (profileImagePath != null &&
                              profileImagePath!.startsWith('http'))
                        ? NetworkImage(profileImagePath!)
                        : const AssetImage('assets/defaultUser.png'),
                  ),
                  if (isEditing)
                    InkWell(
                      onTap: _pickProfileImage,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        padding: const EdgeInsets.all(6.0),
                        child: const Icon(
                          Icons.edit,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              if (isEditing)
                SizedBox(
                  width: 200,
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    controller: usernameController,
                  ),
                )
              else
                Text(
                  username ?? 'Guest',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              const SizedBox(height: 20),
              if (businessProfile == null && !isEditing)
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BusinessProfileTree(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 187),
                    ),
                    child: Column(
                      children: [
                        Image.asset('assets/hammer.png', width: 64, height: 68),
                        const SizedBox(height: 8),
                        Text(
                          'Create HBB Profile',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              if (businessProfile != null)
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomFormField(
                        label: "Business Name",
                        type: FieldType.text,
                        requiredField: true,
                        initialValue: isEditing
                            ? editingBusinessProfile?.name
                            : businessProfile?.name,
                        onSaved: (val) {
                          if (isEditing) {
                            editingBusinessProfile = editingBusinessProfile
                                ?.copyWith(name: val ?? '');
                          }
                        },
                        readOnly: !isEditing,
                      ),
                      const SizedBox(height: 16),
                      CustomFormField(
                        label: "Product Type",
                        type: FieldType.dropdown,
                        requiredField: true,
                        initialValue: isEditing
                            ? editingBusinessProfile?.productType
                            : businessProfile?.productType,
                        onSaved: (val) {
                          if (isEditing) {
                            editingBusinessProfile = editingBusinessProfile
                                ?.copyWith(productType: val ?? '');
                          }
                        },
                        readOnly: !isEditing,
                      ),
                      const SizedBox(height: 16),
                      CustomFormField(
                        label: "Description",
                        type: FieldType.text,
                        requiredField: false,
                        initialValue: isEditing
                            ? editingBusinessProfile?.description
                            : businessProfile?.description,
                        onSaved: (val) {
                          if (isEditing) {
                            editingBusinessProfile = editingBusinessProfile
                                ?.copyWith(description: val ?? '');
                          }
                        },
                        readOnly: !isEditing,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      CustomFormField(
                        key: _imagesKey,
                        label: "Photos",
                        requiredField: false,
                        type: FieldType.images,
                        initialImages: isEditing
                            ? editingBusinessProfile?.imagePaths
                            : businessProfile?.imagePaths,
                        readOnly: !isEditing,
                      ),
                      const SizedBox(height: 20),
                      if (!isEditing && businessProfile != null)
                        ElevatedButton.icon(
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.remove('businessProfile');
                            setState(() => businessProfile = null);
                          },
                          icon: const Icon(Icons.delete),
                          label: const Text('Delete Business Profile'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              if (isEditing)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  child: SizedBox(
                    width: 237,
                    height: 74,
                    child: ElevatedButton(
                      onPressed: _saveAll,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(fontSize: 27, color: Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
