import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// views
import 'package:homebased_project/mvp2/auth/auth_pages/auth_page.dart';
import 'package:homebased_project/backend/auth_api/auth_service.dart';

// utils
import 'package:homebased_project/mvp2/utils/field_status.dart';

class FieldState {
  String value;
  FieldStatus status;
  String? errorMessage;

  FieldState({
    required this.value,
    this.status = FieldStatus.defaultStatus,
    this.errorMessage,
  });
}

class GetResetPasswordEmailPage extends StatefulWidget {
  const GetResetPasswordEmailPage({super.key});

  @override
  State<GetResetPasswordEmailPage> createState() =>
      _GetResetPasswordEmailPage();
}

class _GetResetPasswordEmailPage extends State<GetResetPasswordEmailPage> {
  bool _isLoading = false;

  final TextEditingController emailController = TextEditingController();

  FieldState email = FieldState(value: '');

  FieldState validateEmail(String value) {
    if (value.isEmpty) return FieldState(value: value);
    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!regex.hasMatch(value)) {
      return FieldState(
        value: value,
        status: FieldStatus.error,
        errorMessage: "Please enter a valid email address",
      );
    }
    return FieldState(value: value, status: FieldStatus.success);
  }

  Color getBorderColor(FieldStatus status) {
    switch (status) {
      case FieldStatus.success:
        return Colors.green;
      case FieldStatus.error:
        return Colors.red;
      default:
        return Colors.blue.shade200;
    }
  }

  Future<void> sendResetEmail() async {
    setState(() => _isLoading = true);
    final email = emailController.text.trim();

    try {
      await authService.sendPasswordResetEmail(email: email);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent.')),
      );
      Navigator.pop(context);
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = 32;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Email
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Email",
                    style: TextStyle(color: Color(0xFF5A7A8A), fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: emailController,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "Enter your email",
                      hintStyle: const TextStyle(fontSize: 14),
                      prefixIcon: const Icon(Icons.alternate_email, size: 20),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: getBorderColor(email.status),
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (val) => setState(
                      () => email.status = FieldStatus.defaultStatus,
                    ),
                    onEditingComplete: () => setState(
                      () => email = validateEmail(emailController.text),
                    ),
                  ),
                  if (email.status == FieldStatus.error &&
                      email.errorMessage != null)
                    Text(
                      email.errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 10),
                    ),
                  const SizedBox(height: 12),
                ],
              ),

              const SizedBox(height: 16),

              // Primary Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB885),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _isLoading ? null : sendResetEmail,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Send Reset Password Email"),
              ),

              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const AuthPage()));
                },
                child: const Text(
                  "Back to Login",
                  style: TextStyle(color: Color(0xFF6A8A9A)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
