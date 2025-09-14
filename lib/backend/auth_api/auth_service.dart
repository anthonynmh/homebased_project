import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:homebased_project/backend/supabase_api/supabase_service.dart';

class AuthService {
  static SupabaseClient _supabase = supabase;

  /// For testing: allow overriding the Supabase client
  static void setClient(SupabaseClient client) {
    _supabase = client;
  }

  static void resetClient() {
    _supabase = supabase;
  }

  /// Sign in user with email + password
  static Future<AuthResponse> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign up user with email + password
  static Future<AuthResponse> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      return response;
    } catch (e, st) {
      print('Supabase sign up error: $e\n$st');
      throw Exception('Failed to sign up user: $e');
    }
  }

  /// Sign out user
  static Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Returns the current user (or null if logged out)
  static User? get currentUser => _supabase.auth.currentUser;

  /// Returns the current user's Supabase UUID (or null if logged out)
  static String? get currentUserId => _supabase.auth.currentUser?.id;

  /// Stream of auth state changes
  static Stream<AuthState> get onAuthStateChange =>
      _supabase.auth.onAuthStateChange;
}
