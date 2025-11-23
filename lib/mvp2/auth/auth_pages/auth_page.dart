import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:homebased_project/mvp2/app_components/app_form_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// views
import 'package:homebased_project/views/widget_tree.dart';
import 'package:homebased_project/backend/auth_api/auth_service.dart';
import 'package:homebased_project/widgets/snackbar_widget.dart';
import 'package:homebased_project/backend/user_profile_api/user_profile_model.dart';
import 'package:homebased_project/backend/user_profile_api/user_profile_service.dart';
import 'package:homebased_project/mvp2/auth/auth_pages/reset_password_page.dart';
import 'package:homebased_project/mvp2/auth/auth_pages/get_reset_password_email_page.dart';

// components
import 'package:homebased_project/mvp2/auth/auth_components/auth_header.dart';
import 'package:homebased_project/mvp2/auth/auth_components/auth_tabs.dart';
import 'package:homebased_project/mvp2/auth/auth_components/auth_text_field.dart';
import 'package:homebased_project/mvp2/auth/auth_components/auth_divider.dart';
import 'package:homebased_project/mvp2/auth/auth_components/google_button.dart';

// utils
import 'package:homebased_project/mvp2/utils/field_status.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLoading = false;
  bool _redirecting = false;
  bool isSignUp = false;
  bool _hasAcceptedTerms = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  late final StreamSubscription<AuthState> _authStateSubscription;

  FieldState name = FieldState(value: "");
  FieldState email = FieldState(value: "");
  FieldState password = FieldState(value: "");
  FieldState confirmPassword = FieldState(value: "");

  @override
  void initState() {
    super.initState();
    _authStateSubscription = authService.onAuthStateChange.listen(
      (data) {
        final event = data.event;

        if (event == AuthChangeEvent.passwordRecovery) {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
          );
        } else {
          if (_redirecting) return;
          final session = data.session;
          if (session != null) {
            _redirecting = true;
            if (!mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const WidgetTree()),
            );
          }
        }
      },
      onError: (error) {
        if (!mounted) return;
        final message = error is AuthException
            ? error.message
            : 'Unexpected error occurred';
        context.showSnackBar(message, isError: true);
      },
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _authStateSubscription.cancel();
    super.dispose();
  }

  // Validation helpers
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

  FieldState validatePassword(String value) {
    if (value.isEmpty) return FieldState(value: value);
    if (value.length < 8) {
      return FieldState(
        value: value,
        status: FieldStatus.error,
        errorMessage: "Password must be at least 8 characters",
      );
    }
    return FieldState(value: value, status: FieldStatus.success);
  }

  FieldState validateConfirmPassword(String value) {
    if (value.isEmpty) return FieldState(value: value);
    if (value != password.value) {
      return FieldState(
        value: value,
        status: FieldStatus.error,
        errorMessage: "Passwords do not match",
      );
    }
    return FieldState(value: value, status: FieldStatus.success);
  }

  Future<void> signUp() async {
    if (!_hasAcceptedTerms) {
      context.showSnackBar(
        "You must accept the Terms and Conditions to sign up.",
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await authService.signUpWithEmailPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (res.user != null) {
        if (!mounted) return;
        context.showSnackBar("Signup successful!");
        final profile = UserProfile(id: res.user!.id, email: res.user!.email);
        await userProfileService.insertCurrentUserProfile(profile);
      }
    } catch (e) {
      if (!mounted) return;
      context.showSnackBar("$e", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> signIn() async {
    setState(() => _isLoading = true);
    try {
      final res = await authService.signInWithEmailPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      if (res.session != null) {
        // handled by auth listener
      }
    } on AuthException catch (error) {
      if (!mounted) return;
      context.showSnackBar(error.message, isError: true);
    } catch (_) {
      if (!mounted) return;
      context.showSnackBar('Unexpected error occurred', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final res = await authService.signInWithGoogle();
      if (!res) {
        // handled by auth listener
      }
    } on AuthException catch (error) {
      if (!mounted) return;
      context.showSnackBar(error.message, isError: true);
    } catch (_) {
      if (!mounted) return;
      context.showSnackBar('Unexpected error occurred', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Dialog for Terms and Conditions
  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Terms and Conditions"),
        content: Text(
          "By proceeding, you acknowledge that Food 'n Friends does not oversee or manage home-based businesses (‘HBBs’). Each HBB owner (‘Seller’) operates independently and bears sole responsibility for their products, services, and business practices.",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _hasAcceptedTerms = true);
              Navigator.pop(context);
            },
            child: const Text("I Agree"),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: _hasAcceptedTerms,
              onChanged: (value) =>
                  setState(() => _hasAcceptedTerms = value ?? false),
            ),
            Expanded(
              child: RichText(
                text: TextSpan(
                  text: "Accept the ",
                  style: const TextStyle(color: Colors.black, fontSize: 12),
                  children: [
                    TextSpan(
                      text: "terms and conditions",
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = _showTermsDialog,
                    ),
                    const TextSpan(text: " to sign up."),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double horizontalPadding = 32;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 20),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const AuthHeader(),
                  const SizedBox(height: 16),
                  Text(
                    isSignUp
                        ? "Create your account to get started"
                        : "Log in to get started",
                    style: const TextStyle(
                      color: Color(0xFF6A8A9A),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AuthTabs(
                          isSignUp: isSignUp,
                          onLoginTap: () => setState(() => isSignUp = false),
                          onSignUpTap: () => setState(() => isSignUp = true),
                        ),
                        const SizedBox(height: 24),

                        // Email field
                        AuthTextField(
                          label: "Email",
                          controller: emailController,
                          icon: Icons.alternate_email,
                          status: email.status,
                          onChanged: (_) => setState(() {
                            email.status = FieldStatus.defaultStatus;
                          }),
                          onComplete: () => setState(() {
                            email = validateEmail(emailController.text);
                          }),
                          errorText: email.errorMessage,
                        ),

                        // Password field
                        AuthTextField(
                          label: "Password",
                          controller: passwordController,
                          icon: Icons.lock_outline,
                          obscure: true,
                          status: password.status,
                          onChanged: (_) => setState(() {
                            password.status = FieldStatus.defaultStatus;
                          }),
                          onComplete: () => setState(() {
                            password = validatePassword(
                              passwordController.text,
                            );
                          }),
                          errorText: password.errorMessage,
                        ),

                        if (!isSignUp)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Forgot your password? "),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const GetResetPasswordEmailPage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Click here",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                        // Confirm password (only if sign up)
                        if (isSignUp)
                          AuthTextField(
                            label: "Confirm Password",
                            controller: confirmPasswordController,
                            icon: Icons.lock_outline,
                            obscure: true,
                            status: confirmPassword.status,
                            onChanged: (_) => setState(() {
                              confirmPassword.status =
                                  FieldStatus.defaultStatus;
                            }),
                            onComplete: () => setState(() {
                              confirmPassword = validateConfirmPassword(
                                confirmPasswordController.text,
                              );
                            }),
                            errorText: confirmPassword.errorMessage,
                          ),

                        if (isSignUp) _buildTermsSection(),
                        const SizedBox(height: 16),
                        AppFormButton(
                          label: isSignUp ? "Create Account" : "Log In",
                          isLoading: _isLoading,
                          onPressed: _isLoading
                              ? null
                              : isSignUp
                              ? (_hasAcceptedTerms ? signUp : null)
                              : signIn,
                        ),
                        const SizedBox(height: 16),
                        const AuthDivider(),
                        const SizedBox(height: 16),
                        GoogleButton(
                          isLoading: _isLoading,
                          onPressed: signInWithGoogle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
