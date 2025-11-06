import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:homebased_project/views/widget_tree.dart';
import 'package:homebased_project/backend/auth_api/auth_service.dart';
import 'package:homebased_project/widgets/snackbar_widget.dart';
import 'package:homebased_project/backend/user_profile_api/user_profile_model.dart';
import 'package:homebased_project/backend/user_profile_api/user_profile_service.dart';
import 'package:homebased_project/mvp2/auth/reset_password_page.dart';
import 'package:homebased_project/mvp2/auth/get_reset_password_email_page.dart';

enum FieldStatus { defaultStatus, success, error }

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

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AppState();
}

class _AppState extends State<AuthPage> {
  bool _isLoading = false;
  bool _redirecting = false;
  bool isSignUp = false;

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
        if (error is AuthException) {
          if (!mounted) return;
          context.showSnackBar(error.message, isError: true);
        } else {
          if (!mounted) return;
          context.showSnackBar('Unexpected error occurred', isError: true);
        }
      },
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _authStateSubscription.cancel();
    super.dispose();
  }

  FieldState validateName(String value) {
    if (value.isEmpty) return FieldState(value: value);
    if (value.length < 2) {
      return FieldState(
        value: value,
        status: FieldStatus.error,
        errorMessage: "Name must be at least 2 characters",
      );
    }
    return FieldState(value: value, status: FieldStatus.success);
  }

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

  Color getIconColor(FieldStatus status) {
    switch (status) {
      case FieldStatus.success:
        return Colors.green;
      case FieldStatus.error:
        return Colors.red;
      default:
        return Colors.blue.shade200;
    }
  }

  Future<void> signUp() async {
    setState(() => _isLoading = true);

    try {
      final res = await authService.signUpWithEmailPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (res.user != null) {
        if (!mounted) return;
        context.showSnackBar("Signup successful!");

        // Insert user profile
        final profile = UserProfile(id: res.user!.id, email: res.user!.email);
        await userProfileService.insertCurrentUserProfile(profile);

        if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = 32;
    final size = MediaQuery.of(context).size;

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
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(32, 32, 32, 40),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          Color(0xFFC8E8F8),
                          Color(0xFFE8E0F8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB885),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 4),
                            ],
                          ),
                          child: const Icon(
                            Icons.local_cafe,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Food 'n Friends",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2A4A5A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Community in Selling",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5A7A8A),
                          ),
                        ),
                      ],
                    ),
                  ),
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

                  SizedBox(
                    width: 390,
                    height: 844,
                    child: Column(
                      children: [
                        // Toggle Tabs
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => isSignUp = false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: !isSignUp
                                          ? Colors.white
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: !isSignUp
                                          ? const [
                                              BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 4,
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Log In",
                                        style: TextStyle(
                                          color: !isSignUp
                                              ? const Color(0xFF2A4A5A)
                                              : const Color(0xFF8A9AAA),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => isSignUp = true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSignUp
                                          ? Colors.white
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: isSignUp
                                          ? const [
                                              BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 4,
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Sign Up",
                                        style: TextStyle(
                                          color: isSignUp
                                              ? const Color(0xFF2A4A5A)
                                              : const Color(0xFF8A9AAA),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Form Fields
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Email
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Email",
                                    style: TextStyle(
                                      color: Color(0xFF5A7A8A),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  TextField(
                                    controller: emailController,
                                    style: const TextStyle(fontSize: 14),
                                    decoration: InputDecoration(
                                      hintText: "Enter your email",
                                      hintStyle: const TextStyle(fontSize: 14),
                                      prefixIcon: const Icon(
                                        Icons.alternate_email,
                                        size: 20,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
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
                                      () => email.status =
                                          FieldStatus.defaultStatus,
                                    ),
                                    onEditingComplete: () => setState(
                                      () => email = validateEmail(
                                        emailController.text,
                                      ),
                                    ),
                                  ),
                                  if (email.status == FieldStatus.error &&
                                      email.errorMessage != null)
                                    Text(
                                      email.errorMessage!,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 10,
                                      ),
                                    ),
                                  const SizedBox(height: 12),
                                ],
                              ),

                              // Password
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Password",
                                    style: TextStyle(
                                      color: Color(0xFF5A7A8A),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  TextField(
                                    controller: passwordController,
                                    obscureText: true,
                                    style: const TextStyle(fontSize: 14),
                                    decoration: InputDecoration(
                                      hintText: "Enter your password",
                                      hintStyle: const TextStyle(fontSize: 14),
                                      prefixIcon: const Icon(
                                        Icons.lock_outline,
                                        size: 20,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 16,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: getBorderColor(
                                            password.status,
                                          ),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    onChanged: (val) => setState(
                                      () => password.status =
                                          FieldStatus.defaultStatus,
                                    ),
                                    onEditingComplete: () => setState(
                                      () => password = validatePassword(
                                        passwordController.text,
                                      ),
                                    ),
                                  ),

                                  if (!isSignUp)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                  if (password.status == FieldStatus.error &&
                                      password.errorMessage != null)
                                    Text(
                                      password.errorMessage!,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 10,
                                      ),
                                    ),
                                  const SizedBox(height: 12),
                                ],
                              ),

                              // Confirm Password
                              if (isSignUp)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Confirm Password",
                                      style: TextStyle(
                                        color: Color(0xFF5A7A8A),
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    TextField(
                                      controller: confirmPasswordController,
                                      obscureText: true,
                                      style: const TextStyle(fontSize: 14),
                                      decoration: InputDecoration(
                                        hintText: "Re-enter your password",
                                        hintStyle: const TextStyle(
                                          fontSize: 14,
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.lock_outline,
                                          size: 20,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: 12,
                                              horizontal: 16,
                                            ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          borderSide: BorderSide(
                                            color: getBorderColor(
                                              confirmPassword.status,
                                            ),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      onChanged: (val) => setState(
                                        () => confirmPassword.status =
                                            FieldStatus.defaultStatus,
                                      ),
                                      onEditingComplete: () => setState(
                                        () => confirmPassword =
                                            validateConfirmPassword(
                                              confirmPasswordController.text,
                                            ),
                                      ),
                                    ),
                                    if (confirmPassword.status ==
                                            FieldStatus.error &&
                                        confirmPassword.errorMessage != null)
                                      Text(
                                        confirmPassword.errorMessage!,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 10,
                                        ),
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
                                onPressed: _isLoading
                                    ? null
                                    : isSignUp
                                    ? signUp
                                    : signIn,
                                child: Text(
                                  isSignUp ? "Create Account" : "Log In",
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Divider with text
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Divider(
                                    thickness: 1,
                                    color: Color(0xFFE8F4F8),
                                  ),
                                  Container(
                                    color: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: const Text(
                                      "or continue with",
                                      style: TextStyle(
                                        color: Color(0xFFA8B8C8),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Google Button
                              OutlinedButton.icon(
                                onPressed: _isLoading ? null : signInWithGoogle,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFFE8F4F8),
                                    width: 2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  minimumSize: const Size.fromHeight(44),
                                ),
                                icon: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: SvgPicture.network(
                                    "https://upload.wikimedia.org/wikipedia/commons/3/3c/Google_Favicon_2025.svg",
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                label: const Text(
                                  "Google",
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
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
