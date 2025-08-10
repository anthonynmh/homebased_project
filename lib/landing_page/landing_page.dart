import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:provider/provider.dart';
import 'package:homebased_project/providers/auth_state.dart';
import 'package:homebased_project/home_page/home_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  late Auth0 auth0;

  @override
  void initState() {
    super.initState();
    auth0 = Auth0(
      'dev-vltrrhemn7q01gih.us.auth0.com',
      'bdduBcs7SNMc7MZG4RjIcuGoH4uV0Szn',
    );
  }

  Future<void> _handleAuth0Login() async {
    try {
      final credentials = await auth0
          .webAuthentication(scheme: "demo")
          .login(
            useHTTPS: true, // TODO: set to true for production
          );

      if (!mounted) return;

      // Store auth globally
      Provider.of<AuthState>(
        context,
        listen: false,
      ).setAuth(auth0, credentials);

      // Navigate to home page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MyHomePage()),
      );
    } catch (e) {
      print('Auth0 login error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.house_rounded,
                size: 80,
                color: Colors.deepOrange,
              ),
              const SizedBox(height: 24),
              const Text(
                'Welcome to Homebased App',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Log in or sign up securely with Auth0',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text('Continue with Auth0'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: _handleAuth0Login,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
