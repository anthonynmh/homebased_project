import 'package:flutter/material.dart';
import 'package:homebased_project/models/business_profile.dart';
import 'package:homebased_project/views/pages/business_description_page.dart';
import 'package:homebased_project/views/pages/business_images_page.dart';
import 'package:homebased_project/views/pages/business_name_page.dart';
import 'package:homebased_project/views/pages/business_product_type_page.dart';
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
    description: '',
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

  void updateDescription(String description) {
    setState(() {
      profile.description = description;
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
      BusinessDescriptionPage(
        address: profile.description,
        onAddressChanged: updateDescription,
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
        centerTitle: true,
        leading: currentStep > 0
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: previousStep,
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(10),
                    backgroundColor: Colors.white, // button background
                    elevation: 3, // shadow depth
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ), // back arrow icon
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
      body: IndexedStack(index: currentStep, children: pages),
    );
  }
}
