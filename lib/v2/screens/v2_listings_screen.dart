import 'package:flutter/material.dart';

import 'package:homebased_project/v2/screens/v2_discover_screen.dart';
import 'package:homebased_project/v2/state/v2_app_controller.dart';

class V2ListingsScreen extends StatelessWidget {
  final V2AppController controller;

  const V2ListingsScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return V2DiscoverScreen(controller: controller);
  }
}
