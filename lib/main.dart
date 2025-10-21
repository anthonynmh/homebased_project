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
  const isProd = bool.fromEnvironment('dart.vm.product');

  if (!isProd) {
    // ✅ Local dev only
    try {
      await dotenv.load(fileName: ".env");
      debugPrint("Loaded local .env file");
    } on Exception {
      debugPrint(".env file not found locally — skipping.");
    }
  } else {
    debugPrint("Production mode — skipping .env load.");
  }
}

Future<void> _initializeSupabase() async {
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
