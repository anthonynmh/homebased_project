import 'package:flutter/material.dart';
import 'package:homebased_project/views/map_test.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:homebased_project/landing_page/landing_page.dart';
import 'package:homebased_project/providers/auth_state.dart' as auth_provider;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _loadAndValidateEnv();
  await _initializeSupabase();

  runApp(
    ChangeNotifierProvider(
      create: (_) => auth_provider.AuthState(),
      child: const MyApp(),
    ),
  );
}

/// Loads .env file and validates required variables
Future<void> _loadAndValidateEnv() async {
  try {
    await dotenv.load(fileName: ".env");
  } on Exception {
    throw Exception(".env file not found in the project root.");
  }

  const requiredKeys = [
    'NEXT_PUBLIC_SUPABASE_URL',
    'NEXT_PUBLIC_SUPABASE_ANON_KEY',
  ];

  for (final key in requiredKeys) {
    if ((dotenv.env[key] ?? '').isEmpty) {
      throw Exception('Missing environment variable: $key');
    }
  }
}

/// Initializes Supabase with env variables
Future<void> _initializeSupabase() async {
  final supabaseUrl = dotenv.env['NEXT_PUBLIC_SUPABASE_URL']!;
  final supabaseAnonKey = dotenv.env['NEXT_PUBLIC_SUPABASE_ANON_KEY']!;

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'homebased App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFC23838)),
        fontFamily: 'Inter',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 26.65, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 14),
          labelLarge: TextStyle(fontSize: 14),
          titleLarge: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
      home: const MapScreen(),
      // home: const LandingPage(),
    );
  }
}
