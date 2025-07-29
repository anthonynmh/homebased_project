import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homebased_project/landing_page/landing_page.dart';
import 'package:homebased_project/providers/auth_state.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (_) => AuthState(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'homebased App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      home: const LandingPage(),
    );
  }
}
