import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter/foundation.dart';

import 'package:homebased_project/backend/supabase_api/supabase_service.dart';
import 'package:homebased_project/backend/user_profile_api/user_profile_service.dart';

/// Expose a single AuthService instance that uses the global supabase
final authService = AuthService();

class AuthService {
  final SupabaseClient _supabase;

  AuthService({SupabaseClient? client}) : _supabase = client ?? supabase;

  Future<AuthResponse> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

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

  Future<bool> signInWithGoogle() async {
    return await supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'https://foodnfriends.app/',
      // redirectTo: 'http://localhost:8000/', // for local testing
      authScreenLaunchMode: kIsWeb
          ? LaunchMode.platformDefault
          : LaunchMode
                .externalApplication, // Launch the auth screen in a new webview on mobile.
    );
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    await _supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: 'https://foodnfriends.app/',
      // redirectTo: 'http://localhost:8000/', // for local testing
    );
  }

  Future<void> updatePassword({required String newPassword}) async {
    final res = await _supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );

    if (res.user == null) {
      throw Exception('Failed to update password.');
    }

    // Explicit logout so app returns to clean auth state
    await supabase.auth.signOut();
  }

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
