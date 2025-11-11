import 'dart:async';

import 'package:flutter/gestures.dart';
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
        content: const Text(
          "By proceeding, you acknowledge that Food 'n Friends does not oversee or manage home-based businesses (‘HBBs’). Each HBB owner (‘Seller’) operates independently and bears sole responsibility for their products, services, and business practices.",
          style: TextStyle(fontSize: 14),
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
                  _buildHeader(),
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
                        _buildTabs(),
                        const SizedBox(height: 24),
                        _buildEmailField(),
                        _buildPasswordField(),
                        if (isSignUp) _buildConfirmPasswordField(),
                        if (isSignUp) _buildTermsSection(),
                        const SizedBox(height: 16),
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
                              ? (_hasAcceptedTerms ? signUp : null)
                              : signIn,
                          child: Text(isSignUp ? "Create Account" : "Log In"),
                        ),
                        const SizedBox(height: 16),
                        _buildDivider(),
                        const SizedBox(height: 16),
                        _buildGoogleButton(),
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

  // --- Reusable widget sections ---
  Widget _buildHeader() => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(32, 32, 32, 40),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.white, Color(0xFFC8E8F8), Color(0xFFE8E0F8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Column(
      children: const [
        Icon(Icons.local_cafe, size: 56, color: Color(0xFFFFB885)),
        SizedBox(height: 12),
        Text(
          "Food 'n Friends",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2A4A5A),
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Community in Selling",
          style: TextStyle(fontSize: 12, color: Color(0xFF5A7A8A)),
        ),
      ],
    ),
  );

  Widget _buildTabs() => Row(
    children: [
      Expanded(
        child: GestureDetector(
          onTap: () => setState(() => isSignUp = false),
          child: _buildTab("Log In", !isSignUp),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: GestureDetector(
          onTap: () => setState(() => isSignUp = true),
          child: _buildTab("Sign Up", isSignUp),
        ),
      ),
    ],
  );

  Widget _buildTab(String text, bool active) => Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      color: active ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      boxShadow: active
          ? const [BoxShadow(color: Colors.black12, blurRadius: 4)]
          : null,
    ),
    child: Center(
      child: Text(
        text,
        style: TextStyle(
          color: active ? const Color(0xFF2A4A5A) : const Color(0xFF8A9AAA),
        ),
      ),
    ),
  );

  Widget _buildEmailField() => _buildTextField(
    label: "Email",
    controller: emailController,
    icon: Icons.alternate_email,
    status: email.status,
    onComplete: () =>
        setState(() => email = validateEmail(emailController.text)),
    errorText: email.errorMessage,
  );

  Widget _buildPasswordField() => _buildTextField(
    label: "Password",
    controller: passwordController,
    icon: Icons.lock_outline,
    obscure: true,
    status: password.status,
    onComplete: () =>
        setState(() => password = validatePassword(passwordController.text)),
    errorText: password.errorMessage,
  );

  Widget _buildConfirmPasswordField() => _buildTextField(
    label: "Confirm Password",
    controller: confirmPasswordController,
    icon: Icons.lock_outline,
    obscure: true,
    status: confirmPassword.status,
    onComplete: () => setState(
      () => confirmPassword = validateConfirmPassword(
        confirmPasswordController.text,
      ),
    ),
    errorText: confirmPassword.errorMessage,
  );

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    FieldStatus status = FieldStatus.defaultStatus,
    bool obscure = false,
    required VoidCallback onComplete,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF5A7A8A), fontSize: 12),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: "Enter your $label".toLowerCase(),
            hintStyle: const TextStyle(fontSize: 14),
            prefixIcon: Icon(icon, size: 20),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: getBorderColor(status), width: 2),
            ),
          ),
          onChanged: (_) => setState(() => status = FieldStatus.defaultStatus),
          onEditingComplete: onComplete,
        ),
        if (status == FieldStatus.error && errorText != null)
          Text(
            errorText,
            style: const TextStyle(color: Colors.red, fontSize: 10),
          ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildDivider() => Stack(
    alignment: Alignment.center,
    children: [
      const Divider(thickness: 1, color: Color(0xFFE8F4F8)),
      Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: const Text(
          "or continue with",
          style: TextStyle(color: Color(0xFFA8B8C8), fontSize: 12),
        ),
      ),
    ],
  );

  Widget _buildGoogleButton() => OutlinedButton.icon(
    onPressed: _isLoading ? null : signInWithGoogle,
    style: OutlinedButton.styleFrom(
      side: const BorderSide(color: Color(0xFFE8F4F8), width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
    label: const Text("Google", style: TextStyle(fontSize: 14)),
  );
}
