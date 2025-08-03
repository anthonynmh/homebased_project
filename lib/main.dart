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
      debugShowCheckedModeBanner: false,
      title: 'homebased App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFC23838)),
        fontFamily: 'Inter',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 26.65, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 14),
          labelLarge: TextStyle(fontSize: 14),
          titleLarge: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
      home: const LandingPage(),
    );
  }
}
