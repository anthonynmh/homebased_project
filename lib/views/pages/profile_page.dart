import 'dart:io';

import 'package:flutter/material.dart';
import 'package:homebased_project/models/business_profile.dart';
import 'package:homebased_project/views/business_profile_tree.dart';
import 'package:homebased_project/widgets/image_scroller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? username;
  String? profileImagePath;
  BusinessProfile? businessProfile;

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
    await prefs.setString('businessProfile', profile.toJson());
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
                  : Container(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Container(
                            height: 95,
                            width: 300,
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Business Name',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text(
                                  '${businessProfile?.name ?? ""}',
                                  style: TextStyle(fontSize: 24),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                          Container(
                            height: 95,
                            width: 300,
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Product Type',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text(
                                  '${businessProfile?.productType ?? ""}',
                                  style: TextStyle(fontSize: 24),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            height: 95,
                            width: 300,
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Address',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text(
                                  '${businessProfile?.address ?? ""}',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Photos',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          ImageScroller(
                            imagePaths: businessProfile?.imagePaths ?? [],
                          ),
                          // Add more fields as needed
                          SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.remove('businessProfile');
                              setState(() {
                                businessProfile = null;
                              });
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
