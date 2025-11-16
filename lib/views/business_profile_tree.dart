import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:homebased_project/views/pages/business_description_page.dart';
import 'package:homebased_project/views/pages/business_images_page.dart';
import 'package:homebased_project/views/pages/business_name_page.dart';
import 'package:homebased_project/views/widget_tree.dart';
import 'package:homebased_project/backend/business_profile_api/business_profile_model.dart';
import 'package:homebased_project/backend/business_profile_api/business_profile_service.dart';
import 'package:homebased_project/backend/supabase_api/supabase_service.dart';

class BusinessProfileTree extends StatefulWidget {
  @override
  State<BusinessProfileTree> createState() => _BusinessProfileTreeState();
}

class _BusinessProfileTreeState extends State<BusinessProfileTree> {
  BusinessProfile profile = BusinessProfile(
    id: '',
    businessName: '',
    description: '',
    photoUrls: [],
    updatedAt: '',
  );

  int currentStep = 0;
  bool isLoading = false;

  late final List<Widget> pages;

  final _userProfileService = BusinessProfileService();

  @override
  void initState() {
    super.initState();
    pages = [
      BusinessNamePage(
        name: profile.businessName,
        onNameChanged: updateName,
        onNext: nextStep,
      ),
      BusinessDescriptionPage(
        address: profile.description ?? '',
        onAddressChanged: updateDescription,
        onNext: nextStep,
      ),
      BusinessImagesPage(
        imagePaths: profile.photoUrls ?? [],
        onImagesChanged: updateImages,
        onNext: nextStep,
      ),
    ];
  }

  void updateName(String name) {
    setState(() {
      profile.businessName = name;
    });
  }

  void updateDescription(String description) {
    setState(() {
      profile.description = description;
    });
  }

  void updateImages(List<String> imagePaths) {
    setState(() {
      profile.photoUrls = imagePaths;
    });
  }

  void previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
    }
  }

  Future<void> nextStep() async {
    if (currentStep < pages.length - 1) {
      setState(() => currentStep++);
      return;
    }

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('businessProfile', jsonEncode(profile.toMap()));

      final user = supabase.auth.currentUser;
      if (user != null) {
        profile.id = user.id;
        profile.updatedAt = DateTime.now().toUtc().toIso8601String();
        await _userProfileService.insertCurrentBusinessProfile(profile);
      }

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => WidgetTree()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save business profile: $e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Your HBB'),
        centerTitle: true,
        leading: currentStep > 0
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: previousStep,
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(10),
                    backgroundColor: Colors.white,
                    elevation: 3,
                  ),
                  child: Icon(Icons.arrow_back, color: Colors.black),
                ),
              )
            : null,
        actions: [
          Padding(
            padding: const EdgeInsets.all(0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => WidgetTree()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                padding: EdgeInsets.all(10),
                backgroundColor: Colors.white,
                elevation: 3,
              ),
              child: Icon(Icons.close, color: Colors.red),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          IndexedStack(index: currentStep, children: pages),
          if (isLoading)
            Container(
              color: Colors.black45,
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
