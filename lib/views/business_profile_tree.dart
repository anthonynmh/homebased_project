import 'package:flutter/material.dart';
import 'package:homebased_project/models/business_profile.dart';
import 'package:homebased_project/views/pages/business_address_page.dart';
import 'package:homebased_project/views/pages/business_images_page.dart';
import 'package:homebased_project/views/pages/business_name_page.dart';
import 'package:homebased_project/views/pages/business_product_type_page.dart';
import 'package:homebased_project/views/pages/profile_page.dart';
import 'package:homebased_project/views/widget_tree.dart';
import 'package:shared_preferences/shared_preferences.dart';

//if user reaches this page, it means they have no existing business profile
class BusinessProfileTree extends StatefulWidget {
  @override
  State<BusinessProfileTree> createState() => _BusinessProfileTreeState();
}

class _BusinessProfileTreeState extends State<BusinessProfileTree> {
  BusinessProfile profile = BusinessProfile(
    name: '',
    productType: '',
    address: '',
    imagePaths: null,
  );
  int currentStep = 0;

  void updateProfile(BusinessProfile newProfile) {
    setState(() {
      profile = newProfile;
    });
  }

  void updateName(String name) {
    setState(() {
      profile.name = name;
    });
  }

  void updateProductType(String productType) {
    setState(() {
      profile.productType = productType;
    });
  }

  void updateAddress(String address) {
    setState(() {
      profile.address = address;
    });
  }

  void updateImages(List<String> imagePaths) {
    setState(() {
      profile.imagePaths = imagePaths;
    });
  }

  void nextStep() async {
    if (currentStep < pages.length - 1) {
      setState(() {
        currentStep++;
      });
    } else {
      // Save profile locally in shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('businessProfile', profile.toJson());
      // Navigate to profile page and reset the stack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => WidgetTree()),
        (route) => false,
      );
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
    }
  }

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      BusinessNamePage(
        name: profile.name,
        onNameChanged: updateName,
        onNext: nextStep,
      ),
      BusinessProductTypePage(
        productType: profile.productType,
        onProductTypeChanged: updateProductType,
        onNext: nextStep,
      ),
      BusinessAddressPage(
        address: profile.address,
        onAddressChanged: updateAddress,
        onNext: nextStep,
      ),
      BusinessImagesPage(
        imagePaths: profile.imagePaths,
        onImagesChanged: updateImages,
        onNext: nextStep,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Your HBB'),
        leading: currentStep > 0
            ? IconButton(icon: Icon(Icons.arrow_back), onPressed: previousStep)
            : null,
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => WidgetTree()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: pages[currentStep],
    );
  }
}
