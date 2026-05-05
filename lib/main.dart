import 'package:flutter/material.dart';

import 'package:homebased_project/v2/v2_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const V2App();
  }
}
