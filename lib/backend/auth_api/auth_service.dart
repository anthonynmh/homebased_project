import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:homebased_project/backend/supabase_api/supabase_service.dart';

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
