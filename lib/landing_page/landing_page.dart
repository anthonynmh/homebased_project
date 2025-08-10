import 'package:flutter/material.dart';
import 'package:homebased_project/backend/auth_api/auth_service.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

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
                onPressed: () => AuthService.login(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
