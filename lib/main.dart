import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:homebased_project/mvp2/auth/auth_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _loadAndValidateEnv();

  runApp(const MyApp());
}

Future<void> _loadAndValidateEnv() async {
  const isProd = bool.fromEnvironment('dart.vm.product');

  if (!isProd) {
    // ✅ Local dev only
    try {
      await dotenv.load(fileName: ".env");
      debugPrint("Loaded local .env file");
      await _initializeSupabaseFromDotEnv();
    } on Exception {
      debugPrint(".env file not found locally — skipping.");
    }
  } else {
    debugPrint("Production mode — skipping .env load.");
    await _initializeSupabaseFromDartDefine();
  }
}

Future<void> _initializeSupabaseFromDotEnv() async {
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseAnonKey == null) {
    throw Exception('Supabase URL or Anon Key is not set in .env file.');
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
}

Future<void> _initializeSupabaseFromDartDefine() async {
  const supabaseUrl = bool.hasEnvironment('SUPABASE_URL')
      ? String.fromEnvironment('SUPABASE_URL')
      : '';
  const supabaseAnonKey = bool.hasEnvironment('SUPABASE_ANON_KEY')
      ? String.fromEnvironment('SUPABASE_ANON_KEY')
      : '';

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw Exception('Supabase URL or Anon Key is not set in environment.');
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food \'n Friends',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5A7A8A)),
        fontFamily: 'Inter',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 26.65, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 14),
          labelLarge: TextStyle(fontSize: 14),
          titleLarge: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
      home: const AuthPage(),
    );
  }
}
