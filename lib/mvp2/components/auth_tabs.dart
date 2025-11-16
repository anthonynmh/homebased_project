import 'package:flutter/material.dart';

// components
import 'package:homebased_project/mvp2/components/toggling_tabs.dart';

class AuthTabs extends StatelessWidget {
  final bool isSignUp;
  final VoidCallback onLoginTap;
  final VoidCallback onSignUpTap;

  const AuthTabs({
    super.key,
    required this.isSignUp,
    required this.onLoginTap,
    required this.onSignUpTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TogglingTab(text: "Log In", active: !isSignUp, onTap: onLoginTap),
        const SizedBox(width: 12),
        TogglingTab(text: "Sign Up", active: isSignUp, onTap: onSignUpTap),
      ],
    );
  }
}
