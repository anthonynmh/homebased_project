import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:homebased_project/providers/auth_state.dart';
import 'package:homebased_project/home_page/home_page.dart';
import 'package:homebased_project/backend/user_profile_api/user_profile_service.dart';

class AuthService {
  static final auth0Domain = dotenv.env['AUTH0_DOMAIN'] ?? '';
  static final auth0ClientId = dotenv.env['AUTH0_CLIENT_ID'] ?? '';

  static final Auth0 _auth0 = _createAuth0();

  static Auth0 _createAuth0() {
    if (auth0Domain.isEmpty || auth0ClientId.isEmpty) {
      throw Exception('AUTH0_DOMAIN or AUTH0_CLIENT_ID is missing in .env');
    }
    return Auth0(auth0Domain, auth0ClientId);
  }

  /// Handles Auth0 login and creates a profile only for new signups
  static Future<void> login(BuildContext context) async {
    try {
      final credentials = await _auth0
          .webAuthentication(scheme: "demo")
          .login(
            useHTTPS: false, // TODO: switch to true for production
          );

      // Store Auth0 instance & credentials globally
      Provider.of<AuthState>(
        context,
        listen: false,
      ).setAuth(_auth0, credentials);

      final auth0Sub = credentials.user.sub ?? '';
      final email = credentials.user.email ?? '';

      if (auth0Sub.isEmpty || email.isEmpty) {
        debugPrint("Auth0 returned incomplete data.");
        return;
      }

      // Check if user profile already exists in Supabase
      final existingProfile = await UserProfileService.getProfileByAuth0Sub(
        auth0Sub,
      );

      if (existingProfile == null) {
        // First time signup → create profile
        await UserProfileService.createProfileFromAuth0(
          auth0Sub: auth0Sub,
          email: email,
        );
        print("New user profile created for $email");
      } else {
        print("User already has a profile, skipping creation.");
      }

      // Navigate to home page
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MyHomePage()),
        );
      }
    } catch (e) {
      debugPrint('Auth0 login error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
      }
    }
  }
}
