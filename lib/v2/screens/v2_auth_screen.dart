import 'package:flutter/material.dart';

import 'package:homebased_project/v2/models/v2_marketplace.dart';
import 'package:homebased_project/v2/state/v2_app_controller.dart';

class V2AuthScreen extends StatefulWidget {
  final V2AppController controller;

  const V2AuthScreen({super.key, required this.controller});

  @override
  State<V2AuthScreen> createState() => _V2AuthScreenState();
}

class _V2AuthScreenState extends State<V2AuthScreen> {
  final _emailController = TextEditingController(text: 'demo@communitii.test');
  final _passwordController = TextEditingController(text: 'password');
  bool _signingUp = false;
  V2UserType _userType = V2UserType.casual;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8E2)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: const Color(
                              0xFF176B87,
                            ).withValues(alpha: 0.13),
                            child: const Icon(
                              Icons.storefront,
                              color: Color(0xFF176B87),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Food 'n Friends",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w900),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Storefront discovery prototype',
                                  style: TextStyle(
                                    color: Color(0xFF647067),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment(
                              value: false,
                              icon: Icon(Icons.login_outlined),
                              label: Text('Log in'),
                            ),
                            ButtonSegment(
                              value: true,
                              icon: Icon(Icons.person_add_alt_1_outlined),
                              label: Text('Sign up'),
                            ),
                          ],
                          selected: {_signingUp},
                          onSelectionChanged: (selection) {
                            setState(() => _signingUp = selection.first);
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _continue(),
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<V2UserType>(
                          segments: const [
                            ButtonSegment(
                              value: V2UserType.casual,
                              icon: Icon(Icons.explore_outlined),
                              label: Text('Casual user'),
                            ),
                            ButtonSegment(
                              value: V2UserType.owner,
                              icon: Icon(Icons.storefront_outlined),
                              label: Text('Owner'),
                            ),
                          ],
                          selected: {_userType},
                          onSelectionChanged: (selection) {
                            setState(() => _userType = selection.first);
                          },
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _continue,
                          icon: Icon(
                            _signingUp ? Icons.person_add_alt_1 : Icons.login,
                          ),
                          label: Text(_signingUp ? 'Sign up' : 'Log in'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _continueWithGoogle,
                          icon: const Icon(Icons.account_circle_outlined),
                          label: const Text('Continue with Google'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _continue() {
    if (!_validate()) return;
    final displayName = _emailController.text.trim().split('@').first;
    if (_signingUp) {
      widget.controller.simulateSignup(
        displayName: displayName,
        email: _emailController.text,
        userType: _userType,
      );
    } else {
      widget.controller.simulateLogin(
        displayName: displayName,
        email: _emailController.text,
        userType: _userType,
      );
    }
  }

  void _continueWithGoogle() {
    final email = _emailController.text.trim().isEmpty
        ? 'google-demo@communitii.test'
        : _emailController.text;
    widget.controller.simulateLogin(
      displayName: 'Google demo',
      email: email,
      userType: _userType,
    );
  }

  bool _validate() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (!email.contains('@') || password.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add an email and password first.')),
      );
      return false;
    }
    return true;
  }
}
