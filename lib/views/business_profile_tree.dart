import 'dart:io';
import 'package:flutter/material.dart';
import 'package:homebased_project/backend/business_profile_api/business_profile_model.dart';
import 'package:homebased_project/backend/business_profile_api/business_profile_service.dart';
import 'package:homebased_project/views/pages/business_description_page.dart';
import 'package:homebased_project/views/pages/business_images_page.dart';
import 'package:homebased_project/views/pages/business_map_page/business_map_page.dart';
import 'package:homebased_project/views/pages/business_name_page.dart';
import 'package:homebased_project/views/pages/business_product_type_page.dart';
import 'package:homebased_project/views/widget_tree.dart';

class BusinessProfileTree extends StatefulWidget {
  @override
  State<BusinessProfileTree> createState() => _BusinessProfileTreeState();
}

class _BusinessProfileTreeState extends State<BusinessProfileTree> {
  BusinessProfile profile = BusinessProfile(
    businessName: '',
    sector: '',
    description: '',
    photoUrls: [],
  );

  int currentStep = 0;

  void nextStep() async {
    if (currentStep < _pages.length - 1) {
      setState(() {
        currentStep++;
      });
    } else {
      try {
        print('>>> Updating business profile with payload:');
        print(profile.toMap());
        await BusinessProfileService.updateCurrentBusinessProfile(profile);
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => WidgetTree()),
          (route) => false,
        );
      } catch (e) {
        if (!mounted) return;
        print('Failed to update business profile: $e'); // log raw error too
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save business profile.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
    }
  }

  List<Widget> get _pages => [
    BusinessNamePage(
      name: profile.businessName ?? '',
      onNameChanged: (val) =>
          setState(() => profile = profile.copyWith(businessName: val)),
      onNext: nextStep,
    ),
    BusinessProductTypePage(
      productType: profile.sector ?? '',
      onProductTypeChanged: (val) =>
          setState(() => profile = profile.copyWith(sector: val)),
      onNext: nextStep,
    ),
    BusinessDescriptionPage(
      address: profile.description ?? '',
      onAddressChanged: (val) =>
          setState(() => profile = profile.copyWith(description: val)),
      onNext: nextStep,
    ),
    BusinessMapPage(onNext: nextStep),
    BusinessImagesPage(
      imagePaths: profile.photoUrls,
      onImagesChanged: (paths) async {
        final files = paths.map((p) => File(p)).toList();
        await BusinessProfileService.uploadBusinessPhotos(files);
        final signedUrls =
            await BusinessProfileService.getCurrentBusinessPhotosUrls();
        setState(() {
          profile = profile.copyWith(photoUrls: signedUrls);
        });
      },
      onNext: nextStep,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your HBB'),
        centerTitle: true,
        leading: currentStep > 0
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: previousStep,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: Colors.white,
                    elevation: 3,
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.black),
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
                  MaterialPageRoute(builder: (_) => WidgetTree()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor: Colors.white,
                elevation: 3,
              ),
              child: const Icon(Icons.close, color: Colors.red),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: currentStep, children: _pages),
    );
  }
}
