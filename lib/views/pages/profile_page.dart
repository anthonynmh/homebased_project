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
  BusinessProfile? businessProfile;
  BusinessProfile? editingBusinessProfile;
  final _formKey = GlobalKey<FormState>();
  final _imagesKey = GlobalKey<CustomFormFieldState>();
  bool isEditingBusinessProfile = false;

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
    });
  }

  Future<void> _editProfileUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final newUsername = await _showUsernameDialog();
    if (newUsername != null && newUsername.isNotEmpty) {
      await prefs.setString('username', newUsername);
      setState(() {
        username = newUsername;
      });
    }
  }

  Future<void> _editProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final ImagePicker picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      await prefs.setString('profileImagePath', pickedImage.path);
      setState(() {
        profileImagePath = pickedImage.path;
      });
    }
  }

  Future<String?> _showUsernameDialog() async {
    String? newUsername;
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Username'),
          content: TextField(
            onChanged: (value) {
              newUsername = value;
            },
            decoration: InputDecoration(hintText: 'Enter new username'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(newUsername),
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
        actions: [
          if (businessProfile != null)
            isEditingBusinessProfile
                ? Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.save),
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            _formKey.currentState?.save();
                            businessProfile = editingBusinessProfile;
                            await saveBusinessProfile(businessProfile!);
                            setState(() {
                              isEditingBusinessProfile = false;
                              editingBusinessProfile = null;
                            });
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.cancel),
                        onPressed: () {
                          _formKey.currentState?.reset();
                          setState(() {
                            editingBusinessProfile = null;
                            isEditingBusinessProfile = false;
                          });
                        },
                      ),
                    ],
                  )
                : IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      setState(() {
                        editingBusinessProfile = businessProfile?.copyWith();
                        isEditingBusinessProfile = true;
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
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 20, right: 20),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.transparent,
                      backgroundImage: profileImagePath != null
                          ? FileImage(File(profileImagePath!))
                          : AssetImage('assets/defaultUser.png')
                                as ImageProvider,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _editProfileImage,
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      iconColor: Colors.black,
                      padding: EdgeInsets.all(8.0),
                    ),
                    child: Icon(Icons.edit),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$username',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  ElevatedButton(
                    onPressed: _editProfileUsername,
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      iconColor: Colors.black,
                      padding: EdgeInsets.all(8.0),
                    ),
                    child: Icon(Icons.edit),
                  ),
                ],
              ),
              SizedBox(height: 20),
              businessProfile == null
                  ? Container(
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
                            Image.asset(
                              'assets/hammer.png',
                              width: 64,
                              height: 68,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Create HBB Profile',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ),
                    )
                  : Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomFormField(
                            label: "Business Name",
                            type: FieldType.text,
                            initialValue:
                                (isEditingBusinessProfile
                                        ? editingBusinessProfile
                                        : businessProfile)
                                    ?.name,
                            onSaved: (val) {
                              if (isEditingBusinessProfile) {
                                editingBusinessProfile = editingBusinessProfile
                                    ?.copyWith(name: val ?? "");
                              }
                            },
                            readOnly: !isEditingBusinessProfile,
                          ),
                          SizedBox(height: 16),
                          CustomFormField(
                            label: "Product Type",
                            type: FieldType.dropdown,
                            initialValue:
                                (isEditingBusinessProfile
                                        ? editingBusinessProfile
                                        : businessProfile)
                                    ?.productType,
                            onSaved: (val) {
                              if (isEditingBusinessProfile) {
                                editingBusinessProfile = editingBusinessProfile
                                    ?.copyWith(productType: val ?? "");
                              }
                            },
                            readOnly: !isEditingBusinessProfile,
                          ),
                          SizedBox(height: 16),
                          CustomFormField(
                            label: "Description",
                            type: FieldType.text,
                            initialValue:
                                (isEditingBusinessProfile
                                        ? editingBusinessProfile
                                        : businessProfile)
                                    ?.description,
                            onSaved: (val) {
                              if (isEditingBusinessProfile) {
                                editingBusinessProfile = editingBusinessProfile
                                    ?.copyWith(description: val ?? "");
                              }
                            },
                            readOnly: !isEditingBusinessProfile,
                            maxLines: 3,
                          ),
                          SizedBox(height: 20),
                          CustomFormField(
                            key: _imagesKey,
                            label: "Photos",
                            type: FieldType.images,
                            initialImages: isEditingBusinessProfile
                                ? editingBusinessProfile?.imagePaths
                                : businessProfile?.imagePaths,
                            readOnly: !isEditingBusinessProfile,
                          ),
                          SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
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
            ],
          ),
        ),
      ),
    );
  }
}
