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
  bool _signingUp = true;
  bool _acceptedTerms = false;
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1556911220-bff31c812dba?auto=format&fit=crop&w=1600&q=80',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                const ColoredBox(color: Color(0xFFEAF1EF)),
          ),
          const ColoredBox(color: Color(0x990D1B16)),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8E2)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Communitii',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF17201D),
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _signingUp
                                ? 'Create your storefront discovery account'
                                : 'Welcome back',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF647067),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 22),
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
                          SegmentedButton<V2UserType>(
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
                          if (_signingUp) ...[
                            const SizedBox(height: 12),
                            CheckboxListTile(
                              value: _acceptedTerms,
                              onChanged: (value) {
                                setState(() => _acceptedTerms = value ?? false);
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                              title: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Text('I accept the '),
                                  TextButton(
                                    onPressed: _showTerms,
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(0, 0),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text('terms and data policy'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _signingUp && !_acceptedTerms
                                ? null
                                : _continue,
                            icon: Icon(
                              _signingUp ? Icons.person_add_alt_1 : Icons.login,
                            ),
                            label: Text(
                              _signingUp ? 'Create account' : 'Log in',
                            ),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: _continueWithGoogle,
                            icon: const Icon(Icons.account_circle_outlined),
                            label: const Text('Continue with Google'),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _signingUp = !_signingUp;
                                if (!_signingUp) _acceptedTerms = false;
                              });
                            },
                            child: Text(
                              _signingUp
                                  ? 'Already have an account? Log in'
                                  : 'New to Communitii? Create an account',
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
        ],
      ),
    );
  }

  void _continue() {
    if (!_validate()) return;
    if (_signingUp && !_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Accept the terms to create an account.')),
      );
      return;
    }

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
    if (_signingUp && !_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Accept the terms to create an account.')),
      );
      return;
    }
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

  void _showTerms() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms and data policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Communitii is a frontend-only prototype. By signing up, you agree '
            'that account, storefront, subscription, product, discussion, and '
            'notification data entered here is simulated and stored locally on '
            'this device for prototype use.\n\n'
            'For a Singapore production service, Communitii would handle '
            'personal data under the Personal Data Protection Act 2012 (PDPA), '
            'including notifying users of collection, use, and disclosure '
            'purposes; collecting, using, or disclosing personal data only for '
            'reasonable purposes; allowing consent withdrawal with reasonable '
            'notice; supporting access and correction requests; protecting data '
            'with reasonable security arrangements; limiting retention when data '
            'is no longer needed; and ensuring comparable protection for '
            'overseas transfers.\n\n'
            'No real payments, production authentication, cloud storage, or '
            'account deletion is performed in this prototype.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
