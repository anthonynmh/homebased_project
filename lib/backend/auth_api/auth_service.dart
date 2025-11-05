import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter/foundation.dart';

import 'package:homebased_project/backend/supabase_api/supabase_service.dart';
import 'package:homebased_project/backend/user_profile_api/user_profile_service.dart';

/// Expose a single AuthService instance that uses the global supabase
final authService = AuthService();

class AuthService {
  final SupabaseClient _supabase;

  /// Default constructor uses the global supabase instance
  AuthService({SupabaseClient? client}) : _supabase = client ?? supabase;

  /// Sign in user with email + password
  Future<AuthResponse> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign up user with email + password
  Future<AuthResponse> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Check if user already exists
      final profile = await userProfileService.getCurrentUserProfileByEmail(
        email,
      );

      if (profile != null) {
        throw Exception(
          'User with this email already exists, or email is unverified.',
        );
      }

      // Proceed with signup
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      return response;
    } catch (e) {
      throw Exception('Failed to sign up user: $e');
    }
  }

  // Future<AuthResponse> signInWithGoogle() async {
  Future<bool> signInWithGoogle() async {
    return await supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb
          ? 'http://localhost:8000/'
          : 'my.scheme://my-host', // Latter option for mobile callbacks via deeplinking, won't be an issue for web deployment
      authScreenLaunchMode: kIsWeb
          ? LaunchMode.platformDefault
          : LaunchMode
                .externalApplication, // Launch the auth screen in a new webview on mobile.
    );
  }

  /// Sign out user
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Returns the current user (or null if logged out)
  User? get currentUser => _supabase.auth.currentUser;

  /// Returns the current user's Supabase UUID (or null if logged out)
  String? get currentUserId => _supabase.auth.currentUser?.id;

  /// Stream of auth state changes
  Stream<AuthState> get onAuthStateChange => _supabase.auth.onAuthStateChange;
}
