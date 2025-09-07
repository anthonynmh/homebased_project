import 'dart:async';
import 'package:flutter/material.dart';
import 'package:homebased_project/views/widget_tree.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:homebased_project/backend/auth_api/auth_service.dart';
import 'package:homebased_project/signup_page/signup_page.dart';
import 'package:homebased_project/widgets/snackbar_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  bool _redirecting = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late final StreamSubscription<AuthState> _authStateSubscription;

  @override
  void initState() {
    super.initState();

    // Listen to auth state changes and redirect if user logs in
    _authStateSubscription = AuthService.onAuthStateChange.listen(
      (data) {
        if (_redirecting) return;

        final session = data.session;
        if (session != null) {
          _redirecting = true;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const WidgetTree()),
          );
        }
      },
      onError: (error) {
        if (error is AuthException) {
          context.showSnackBar(error.message, isError: true);
        } else {
          context.showSnackBar('Unexpected error occurred', isError: true);
        }
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authStateSubscription.cancel();
    super.dispose();
  }

  /// Handles sign-in with email + password
  Future<void> signInWithEmail() async {
    setState(() => _isLoading = true);

    try {
      final res = await AuthService.signInWithEmailPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (res.session != null) {
        // Redirect handled by auth listener
      }
    } on AuthException catch (error) {
      context.showSnackBar(error.message, isError: true);
    } catch (_) {
      context.showSnackBar('Unexpected error occurred', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        children: [
          const Text(
            'Sign in with your email and password',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _isLoading ? null : signInWithEmail,
            child: Text(_isLoading ? 'Signing in...' : 'Sign In'),
          ),
          const SizedBox(height: 18),
          TextButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SignupPage()));
            },
            child: const Text("Dont have an account? Sign up"),
          ),
        ],
      ),
    );
  }
}
