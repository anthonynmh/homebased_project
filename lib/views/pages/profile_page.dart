import 'dart:io';

import 'package:flutter/material.dart';
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
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'Guest';
      profileImagePath = prefs.getString('profileImagePath');
      usernameController = TextEditingController(text: username);
    });
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
    }
  }

  Future<void> _saveAll() async {
    // 1) Validate username (always required)
    final uname = usernameController?.text ?? '';
    final usernameEmpty = uname.trim().isEmpty;

    // 2) Validate business form only if it exists
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
      return; // stay in edit mode
    }

    // 3) Save
    _formKey.currentState?.save(); // no-op if form doesn't exist
    final prefs = await SharedPreferences.getInstance();

    // username
    final newUsername = uname.trim();
    await prefs.setString('username', newUsername);
    username = newUsername;

    // profile image
    if (tempProfileImagePath != null) {
      await prefs.setString('profileImagePath', tempProfileImagePath!);
      profileImagePath = tempProfileImagePath;
    }

    // business profile (only if it exists)
    if (businessProfile != null && editingBusinessProfile != null) {
      // ensure latest images are included
      final images = _imagesKey.currentState?.getImages() ?? [];
      editingBusinessProfile = editingBusinessProfile!.copyWith(
        imagePaths: images,
      );

      businessProfile = editingBusinessProfile;
      await saveBusinessProfile(businessProfile!);
    }

    setState(() {
      tempProfileImagePath = null;
      isEditing = false;
      editingBusinessProfile = null;
    });
  }

  void _cancelAll() {
    setState(() {
      tempProfileImagePath = null;
      usernameController?.text = username ?? 'Guest';
      editingBusinessProfile = null;
      isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          isEditing
              ? Row(
                  children: [
                    IconButton(icon: Icon(Icons.cancel), onPressed: _cancelAll),
                  ],
                )
              : IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    setState(() {
                      editingBusinessProfile = businessProfile?.copyWith();
                      isEditing = true;
                      tempProfileImagePath = profileImagePath;
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // profile image and username
              Stack(
                alignment: Alignment
                    .bottomRight, // place edit button at bottom-right corner of avatar
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.transparent,
                    backgroundImage:
                        (isEditing
                                ? (tempProfileImagePath ?? profileImagePath)
                                : profileImagePath) !=
                            null
                        ? FileImage(
                            File(
                              (isEditing
                                  ? tempProfileImagePath ?? profileImagePath
                                  : profileImagePath)!,
                            ),
                          )
                        : const AssetImage('assets/defaultUser.png')
                              as ImageProvider,
                  ),
                  if (isEditing)
                    InkWell(
                      onTap: _pickProfileImage,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red, // background for visibility
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

              SizedBox(height: 20),
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
                  username ?? "Guest",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              SizedBox(height: 20),
              //if no business profile and not editing, show create button
              if (businessProfile == null && !isEditing)
                Container(
                  padding: EdgeInsets.all(16.0),
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
                      minimumSize: Size(double.infinity, 187),
                    ),
                    child: Column(
                      children: [
                        Image.asset('assets/hammer.png', width: 64, height: 68),
                        SizedBox(height: 8),
                        Text(
                          'Create HBB Profile',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              //if have business profile or editing, show form
              if (businessProfile != null)
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomFormField(
                        label: "Business Name",
                        type: FieldType.text,
                        requiredField: true,
                        initialValue:
                            (isEditing
                                    ? editingBusinessProfile
                                    : businessProfile)
                                ?.name,
                        onSaved: (val) {
                          if (isEditing) {
                            editingBusinessProfile = editingBusinessProfile
                                ?.copyWith(name: val ?? "");
                          }
                        },
                        readOnly: !isEditing,
                      ),
                      SizedBox(height: 16),
                      CustomFormField(
                        label: "Product Type",
                        type: FieldType.dropdown,
                        requiredField: true,
                        initialValue:
                            (isEditing
                                    ? editingBusinessProfile
                                    : businessProfile)
                                ?.productType,
                        onSaved: (val) {
                          if (isEditing) {
                            editingBusinessProfile = editingBusinessProfile
                                ?.copyWith(productType: val ?? "");
                          }
                        },
                        readOnly: !isEditing,
                      ),
                      SizedBox(height: 16),
                      CustomFormField(
                        label: "Description",
                        type: FieldType.text,
                        requiredField: false,
                        initialValue:
                            (isEditing
                                    ? editingBusinessProfile
                                    : businessProfile)
                                ?.description,
                        onSaved: (val) {
                          if (isEditing) {
                            editingBusinessProfile = editingBusinessProfile
                                ?.copyWith(description: val ?? "");
                          }
                        },
                        readOnly: !isEditing,
                        maxLines: 3,
                      ),
                      SizedBox(height: 20),
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
                      SizedBox(height: 20),
                      if (!isEditing && businessProfile != null)
                        ElevatedButton.icon(
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.remove('businessProfile');
                            setState(() => businessProfile = null);
                          },
                          icon: Icon(Icons.delete),
                          label: Text('Delete Business Profile'),
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
                      child: Text(
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
