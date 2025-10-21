import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:homebased_project/login_page/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _loadAndValidateEnv();
  await _initializeSupabase();

  runApp(const MyApp());
}

Future<void> _loadAndValidateEnv() async {
  try {
    // Try loading from .env (works locally)
    await dotenv.load(fileName: ".env");
  } catch (_) {
    // Ignore missing file in production — Netlify injects vars via environment
  }

  const requiredKeys = ['SUPABASE_URL', 'SUPABASE_ANON_KEY'];

  for (final key in requiredKeys) {
    final value =
        dotenv.env[key] ?? String.fromEnvironment(key, defaultValue: '');
    if (value.isEmpty) {
      throw Exception('Missing environment variable: $key');
    }
  }
}

Future<void> _initializeSupabase() async {
  final supabaseUrl =
      dotenv.env['SUPABASE_URL'] ??
      const String.fromEnvironment('SUPABASE_URL');
  final supabaseAnonKey =
      dotenv.env['SUPABASE_ANON_KEY'] ??
      const String.fromEnvironment('SUPABASE_ANON_KEY');

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Knock Knock',
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
      home: const LoginPage(),
    );
  }
}
