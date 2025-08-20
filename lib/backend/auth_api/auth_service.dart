import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homebased_project/backend/supabase_api/supabase_service.dart';

class AuthService {
  /// Sign in user with email + password
  static Future<AuthResponse> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign up user with email + password
  static Future<AuthResponse> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signUp(email: email, password: password);
  }

  /// Sign out user
  static Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  /// Returns the current user (or null if logged out)
  static User? get currentUser => supabase.auth.currentUser;

  /// Stream of auth state changes
  static Stream<AuthState> get onAuthStateChange =>
      supabase.auth.onAuthStateChange;
}
