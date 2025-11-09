import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';

import 'package:homebased_project/backend/auth_api/auth_service.dart';
import 'package:homebased_project/backend/user_profile_api/user_profile_service.dart';
import 'package:homebased_project/backend/user_profile_api/user_profile_model.dart';
import 'login_details.dart';

void main() {
  late AuthService authService;
  late UserProfileService userProfileService;
  late SupabaseClient adminClient;
  late String tableName;
  late final String supabaseServiceRoleKey;

  User? userA;
  User? userB;

  setUpAll(() async {
    await dotenv.load(fileName: ".env");

    final supabaseUrl = dotenv.env['SUPABASE_URL']!;
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;
    // supabaseServiceRoleKey = dotenv.env['SUPABASE_SECRET_KEY']!;
    tableName = dotenv.env['USER_PROFILE_TABLE_STAGING']!;

    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

    authService = AuthService(client: Supabase.instance.client);
    userProfileService = UserProfileService(
      client: Supabase.instance.client,
      isTest: true,
    );

    // adminClient = SupabaseClient(supabaseUrl, supabaseServiceRoleKey);
  });

  group('e2e tests', () {
    testWidgets('UserProfileService end-to-end integration', (tester) async {
      await tester.runAsync(() async {
        final signInResponse = await authService.signInWithEmailPassword(
          email: TestUserConstants.emailA,
          password: TestUserConstants.passwordA,
        );
        userA = signInResponse.user;
        expect(userA, isNotNull);
      });

      while (Supabase.instance.client.auth.currentSession == null) {
        await Future.delayed(const Duration(milliseconds: 50));
      }

      print("Sign in complete.");

      // --- 2️⃣ Insert initial profile via RPC ---
      await tester.runAsync(() async {
        final initialProfile = UserProfile(
          id: authService.currentUserId!,
          email: userA!.email,
          username: 'InitialUser',
          fullName: 'Integration Test User',
        );

        await userProfileService.insertCurrentUserProfile(
          initialProfile,
          isTest: true,
        );

        print("User profile inserted.");
      });

      await tester.runAsync(() async {
        final fetchedProfile = await userProfileService.getCurrentUserProfile(
          authService.currentUserId!,
        );
        print("User profile obtained.");

        expect(fetchedProfile, isNotNull);
        expect(fetchedProfile!.email, equals(TestUserConstants.emailA));
        print('✅ Inserted and fetched user profile successfully.');
      });

      // --- 3️⃣ Update username + full name ---
      await tester.runAsync(() async {
        final updatedProfile = UserProfile(
          id: authService.currentUserId!,
          username: 'UpdatedUser',
          fullName: 'Updated Full Name',
        );
        await userProfileService.updateCurrentUserProfile(updatedProfile);

        final updated = await userProfileService.getCurrentUserProfile(
          authService.currentUserId!,
        );
        expect(updated!.username, equals('UpdatedUser'));
        expect(updated.fullName, equals('Updated Full Name'));
        print('✅ Updated user profile successfully.');
      });

      // --- 4️⃣ Upload avatar to Supabase storage ---
      await tester.runAsync(() async {
        print("Avatar test begin");
        final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        final fakeImage = XFile.fromData(
          bytes, 
          name: 'fakeImage.png',
          mimeType: 'image/png');

        print("Fake image created successfully");
        
        await userProfileService.uploadAvatar(
          fakeImage,
          authService.currentUserId!,
        );

        final withAvatar = await userProfileService.getCurrentUserProfile(
          authService.currentUserId!,
        );
        expect(withAvatar!.avatarUrl, isNotNull);
        print('✅ Uploaded avatar and stored file path: ${withAvatar.avatarUrl}');
      });

      // --- 5️⃣ Retrieve signed avatar URL ---
      await tester.runAsync(() async {
        final signedUrl = await userProfileService.getAvatarUrl(
          authService.currentUserId!,
        );
        expect(signedUrl, isNotNull);
        expect(signedUrl!.startsWith('http'), true);
        print('✅ Retrieved signed URL: $signedUrl');
      });

      // Cleanup: remove all files in user's own folder
      await tester.runAsync(() async {
        await userProfileService.deleteAvatar(authService.currentUserId!);
        print('✅ Cleaned up uploaded avatar files for userA');
      });

      // --- 6️⃣ Sign out cleanup ---
      await tester.runAsync(() async {
        await authService.signOut();
        expect(authService.currentUser, isNull);
        print('✅ Signed out successfully.');
      });
      
    });
  });

  group('RLS enforcement tests', () {
    setUpAll(() async {
      // Insert initial profiles for user A
      final signInResponseA = await authService.signInWithEmailPassword(
        email: TestUserConstants.emailA,
        password: TestUserConstants.passwordA,
      );
      userA = signInResponseA.user;
      expect(userA, isNotNull);

      await userProfileService.insertCurrentUserProfile(
        UserProfile(id: userA!.id, email: userA!.email, username: 'UserA'),
        isTest: true,
      );
      await authService.signOut();

      // Insert initial profiles for user B
      final signInResponseB = await authService.signInWithEmailPassword(
        email: TestUserConstants.emailB,
        password: TestUserConstants.passwordB,
      );
      userB = signInResponseB.user;
      expect(userB, isNotNull);

      await authService.signInWithEmailPassword(
        email: TestUserConstants.emailB,
        password: TestUserConstants.passwordB,
      );
      await userProfileService.insertCurrentUserProfile(
        UserProfile(id: userB!.id, email: userB!.email, username: 'UserB'),
        isTest: true,
      );
      await authService.signOut();
    });

    // tearDownAll(() async {
    //   final users = [userA, userB];
    //   for (var user in users) {
    //     if (user == null) continue;

    //     try {
    //       await adminClient.from(tableName).delete().eq('id', user.id);
    //       print('✅ Deleted profile row for ${user.id}');
    //     } catch (e) {
    //       print('⚠️ Failed to delete profile row for ${user.id}: $e');
    //     }
    //   }
    // });

    testWidgets('User A cannot read User B profile', (tester) async {
      await authService.signInWithEmailPassword(
        email: TestUserConstants.emailA,
        password: TestUserConstants.passwordA,
      );

      final result = await Supabase.instance.client
          .from(tableName)
          .select()
          .eq('id', userB!.id)
          .maybeSingle();

      expect(result, isNull);
      await authService.signOut();
    });

    testWidgets('User A cannot update User B profile', (tester) async {
      await authService.signInWithEmailPassword(
        email: TestUserConstants.emailA,
        password: TestUserConstants.passwordA,
      );

      try {
        await userProfileService.updateCurrentUserProfile(
          UserProfile(id: userB!.id, username: 'HackedByA'),
        );
      } catch (e) {
        print('Caught expected error: $e');
      }

      // final res = await adminClient
      //     .from(tableName)
      //     .select()
      //     .eq('id', userB!.id)
      //     .maybeSingle();
      
      final profileB = await userProfileService.getCurrentUserProfile(
        userB!.id,
      );

      if (profileB != null) {
        expect(profileB.username, isNot('HackedByA'));
      }

      await authService.signOut();
    });

    testWidgets('User A cannot delete User B profile', (tester) async {
      await authService.signInWithEmailPassword(
        email: TestUserConstants.emailA,
        password: TestUserConstants.passwordA,
      );

      try {
        await Supabase.instance.client
            .from(tableName)
            .delete()
            .eq('id', userB!.id);
        final res = await adminClient
            .from(tableName)
            .select()
            .eq('id', userB!.id)
            .maybeSingle();
        expect(res, isNotNull);
      } catch (e) {
        print('Caught unexpected error: $e');
      }

      await authService.signOut();
    });

    testWidgets('User A cannot upload to User B storage folder', (
      tester,
    ) async {
      await authService.signInWithEmailPassword(
        email: TestUserConstants.emailA,
        password: TestUserConstants.passwordA,
      );

      final tempDir = await getTemporaryDirectory();
      final fakeFile = File('${tempDir.path}/hack.png');
      await fakeFile.writeAsBytes(List<int>.filled(256, 42));

      final storage = Supabase.instance.client.storage.from('avatars-staging');
      final path = '${userB!.id}/hack.png';

      try {
        await storage.upload(path, fakeFile);
      } catch (e) {
        print('Caught expected error: $e');
        expect(
          (e as StorageException).message,
          contains("new row violates row-level security policy"),
        );
      }

      final res = await adminClient.storage
          .from('avatars-staging')
          .list(path: userB!.id);

      expect(res, isEmpty);

      await authService.signOut();
    });
  });
}
