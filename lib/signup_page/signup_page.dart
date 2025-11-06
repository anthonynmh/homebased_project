import 'package:flutter/material.dart';
import 'package:homebased_project/backend/auth_api/auth_service.dart';
import 'package:homebased_project/backend/user_profile_api/user_profile_model.dart';
import 'package:homebased_project/backend/user_profile_api/user_profile_service.dart';
import 'package:homebased_project/views/pages/terms_and_conditions_page.dart';
import 'package:homebased_project/login_page/login_page.dart';
import 'package:homebased_project/widgets/snackbar_widget.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    setState(() => _isLoading = true);

    try {
      final res = await authService.signUpWithEmailPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (res.user != null) {
        context.showSnackBar("Signup successful!");

        // Insert user profile
        final profile = UserProfile(id: res.user!.id, email: res.user!.email);
        await userProfileService.insertCurrentUserProfile(profile);

        if (!mounted) return;
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
      }
    } catch (e) {
      if (!mounted) return;
      context.showSnackBar("Unexpected error occurred: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Home icon (from assets)
            Image.asset(
              'assets/ion_home.png',
              width: 60,
              height: 60,
              color: const Color(0xFFFF7949),
            ),
            const SizedBox(height: 20),

            // Orange container with roof shape
            Expanded(
              child: ClipPath(
                clipper: RoofClipper(),
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFFF7949),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Padding(
                        padding: EdgeInsets.only(
                          top: constraints.maxHeight * 0.15, // align after roof
                          left: 24,
                          right: 24,
                          bottom: 32,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "New Account",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Email field
                            _buildInputField(
                              label: "Email",
                              controller: _emailController,
                              obscure: false,
                            ),
                            const SizedBox(height: 16),

                            // Password field
                            _buildInputField(
                              label: "Password",
                              controller: _passwordController,
                              obscure: true,
                            ),
                            const SizedBox(height: 28),
                            // Terms and conditions checkbox
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Checkbox(
                                  value: _agreedToTerms,
                                  onChanged: (value) async {
                                    if (value == true) {
                                      final accepted =
                                          await Navigator.push<bool>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => const TermsPage(),
                                            ),
                                          );
                                      setState(() {
                                        _agreedToTerms = accepted ?? false;
                                      });
                                    } else {
                                      setState(() {
                                        _agreedToTerms = false;
                                      });
                                    }
                                  },
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    final accepted = await Navigator.push<bool>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const TermsPage(),
                                      ),
                                    );
                                    setState(() {
                                      _agreedToTerms = accepted ?? false;
                                    });
                                  },
                                  child: const Text(
                                    "I agree to the Terms and Conditions",
                                    style: TextStyle(
                                      color: Colors.white,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Sign Up button
                            ElevatedButton(
                              onPressed: _isLoading || !_agreedToTerms
                                  ? null
                                  : _signUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 80,
                                  vertical: 14,
                                ),
                                elevation: 3,
                              ),
                              child: Text(
                                _isLoading ? "Signing up..." : "Sign Up",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _agreedToTerms
                                      ? Color(0xFFFF7949)
                                      : Colors.grey,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Back to login
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => const LoginPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Already have an account? Back to Login",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
  }) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(37.27), // same as login
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              border: InputBorder.none, // same as login page
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Custom clipper for roof shape
class RoofClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // Start from bottom left
    path.lineTo(0, size.height * 0.15);

    // Left diagonal up
    path.lineTo(size.width / 2, 0);

    // Right diagonal down
    path.lineTo(size.width, size.height * 0.15);

    // Down to bottom right
    path.lineTo(size.width, size.height);

    // Back to bottom left
    path.lineTo(0, size.height);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
