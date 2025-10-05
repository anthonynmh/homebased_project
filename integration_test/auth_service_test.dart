import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:homebased_project/backend/auth_api/auth_service.dart';

void main() {
  late AuthService authService;
  late SupabaseClient adminClient;
  User? user;

  setUpAll(() async {
    await dotenv.load(fileName: ".env");

    final supabaseUrl = dotenv.env['SUPABASE_URL']!;
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;
    final supabaseServiceRoleKey = dotenv.env['SUPABASE_SECRET_KEY']!;

    // Initialize normal Supabase client (for user operations)
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

    // Use that for your app logic
    authService = AuthService(client: Supabase.instance.client);

    // Create a separate admin client (for deleting test users)
    adminClient = SupabaseClient(supabaseUrl, supabaseServiceRoleKey);
  });

  tearDownAll(() async {
    if (user != null) {
      try {
        await adminClient.auth.admin.deleteUser(user!.id);
        print('✅ Cleaned up test user ${user!.email}');
      } catch (e) {
        print('⚠️ Failed to delete test user: $e');
      }
    }
  });

  testWidgets('Sign up, sign in, sign out (integration)', (tester) async {
    final email =
        'test_integration_${DateTime.now().millisecondsSinceEpoch}@example.com';
    const password = 'securepassword123';

    // Clean up in case the test user already exists
    try {
      await authService.signInWithEmailPassword(
        email: email,
        password: password,
      );
      await authService.signOut();
    } catch (_) {}

    // Sign up
    final signUpResponse = await authService.signUpWithEmailPassword(
      email: email,
      password: password,
    );
    expect(signUpResponse.user, isNotNull);
    user = signUpResponse.user; // 👈 Assign here for cleanup later

    // Sign in
    final signInResponse = await authService.signInWithEmailPassword(
      email: email,
      password: password,
    );
    expect(signInResponse.user, isNotNull);

    // Check current user
    expect(authService.currentUser?.email, equals(email));

    // Sign out
    await authService.signOut();
    expect(authService.currentUser, isNull);
  });
}
