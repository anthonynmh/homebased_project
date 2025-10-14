import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:homebased_project/backend/auth_api/auth_service.dart';
import 'package:homebased_project/backend/business_profile_api/business_profile_service.dart';
import 'package:homebased_project/backend/business_profile_api/business_profile_model.dart';

void main() {
  late AuthService authService;
  late BusinessProfileService businessProfileService;
  late SupabaseClient adminClient;
  late String tableName;
  late String bucketName;

  User? userA;
  User? userB;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env");

    final supabaseUrl = dotenv.env['SUPABASE_URL']!;
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;
    final supabaseServiceRoleKey = dotenv.env['SUPABASE_SECRET_KEY']!;
    tableName = dotenv.env['BUSINESS_PROFILE_TABLE_STAGING']!;
    bucketName = dotenv.env['BUSINESS_PROFILE_BUCKET_STAGING']!;

    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

    authService = AuthService(client: Supabase.instance.client);
    businessProfileService = BusinessProfileService(
      client: Supabase.instance.client,
      isTest: true,
    );

    adminClient = SupabaseClient(supabaseUrl, supabaseServiceRoleKey);
  });

  group('BusinessProfileService e2e tests', () {
    tearDownAll(() async {
      final users = [userA, userB];
      for (var user in users) {
        if (user == null) continue;

        try {
          await adminClient.from(tableName).delete().eq('id', user.id);
          print('✅ Deleted business profile row for ${user.id}');
        } catch (e) {
          print('⚠️ Failed to delete business profile row for ${user.id}: $e');
        }

        try {
          await adminClient.auth.admin.deleteUser(user.id);
          print('✅ Deleted auth user ${user.email}');
        } catch (e) {
          print('⚠️ Failed to delete auth user ${user.email}: $e');
        }
      }
    });

    testWidgets('BusinessProfileService full integration', (tester) async {
      // --- 1️⃣ Sign up test user ---
      final email =
          'biz_test_${DateTime.now().millisecondsSinceEpoch}@example.com';
      const password = 'strongpassword123';

      final signUpResponse = await authService.signUpWithEmailPassword(
        email: email,
        password: password,
      );
      userA = signUpResponse.user;
      expect(userA, isNotNull);

      // --- 2️⃣ Insert initial business profile ---
      final newProfile = BusinessProfile(
        id: authService.currentUserId!,
        businessName: 'Test Biz',
        description: 'Integration test company',
        sector: 'Retail',
      );

      await businessProfileService.insertCurrentBusinessProfile(newProfile);
      final fetched = await businessProfileService.getCurrentBusinessProfile(
        authService.currentUserId!,
      );

      expect(fetched, isNotNull);
      expect(fetched!.businessName, equals('Test Biz'));
      print('✅ Inserted and fetched business profile successfully.');

      // --- 3️⃣ Update business details ---
      final updatedProfile = BusinessProfile(
        id: authService.currentUserId!,
        businessName: 'Updated Biz',
        description: 'Now with more testing',
        sector: 'Tech',
      );

      await businessProfileService.updateCurrentBusinessProfile(
        updatedProfile,
        authService.currentUserId!,
      );

      final updated = await businessProfileService.getCurrentBusinessProfile(
        authService.currentUserId!,
      );
      expect(updated!.businessName, equals('Updated Biz'));
      expect(updated.sector, equals('Tech'));
      print('✅ Updated business profile successfully.');

      // --- 4️⃣ Upload business logo ---
      final tempDir = await getTemporaryDirectory();
      final fakeLogo = File('${tempDir.path}/fake_logo.png');
      await fakeLogo.writeAsBytes(List<int>.filled(128, 42));

      await businessProfileService.uploadBusinessLogo(
        fakeLogo,
        authService.currentUserId!,
      );

      final withLogo = await businessProfileService.getCurrentBusinessProfile(
        authService.currentUserId!,
      );
      expect(withLogo!.logoUrl, isNotNull);
      print('✅ Uploaded business logo and stored path: ${withLogo.logoUrl}');

      // --- 5️⃣ Retrieve signed logo URL ---
      final signedLogoUrl = await businessProfileService
          .getCurrentBusinessLogoUrl(authService.currentUserId!);
      expect(signedLogoUrl, isNotNull);
      expect(signedLogoUrl!.startsWith('http'), true);
      print('✅ Retrieved signed logo URL: $signedLogoUrl');

      // --- 6️⃣ Upload multiple business photos ---
      final fakePhoto1 = File('${tempDir.path}/photo1.png');
      final fakePhoto2 = File('${tempDir.path}/photo2.png');
      await fakePhoto1.writeAsBytes(List<int>.filled(128, 99));
      await fakePhoto2.writeAsBytes(List<int>.filled(128, 88));

      await businessProfileService.uploadBusinessPhotos([
        fakePhoto1,
        fakePhoto2,
      ], authService.currentUserId!);

      final photoUrls = await businessProfileService
          .getCurrentBusinessPhotosUrls(authService.currentUserId!);
      expect(photoUrls, isNotEmpty);
      expect(photoUrls.first.startsWith('http'), true);
      print('✅ Uploaded business photos and retrieved signed URLs.');

      // --- 7️⃣ Search by sector ---
      final techProfiles = await businessProfileService
          .searchBusinessProfilesBySector('Tech');
      expect(techProfiles.any((p) => p.id == authService.currentUserId!), true);
      print('✅ Search by sector works.');

      await authService.signOut();
      expect(authService.currentUser, isNull);
      print('✅ Signed out successfully.');
    });
  });

  group('BusinessProfileService RLS enforcement tests', () {
    setUpAll(() async {
      // Sign up two users
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final emailA = 'bizA_$timestamp@example.com';
      final emailB = 'bizB_$timestamp@example.com';
      const password = 'strongpassword123';

      final signUpA = await authService.signUpWithEmailPassword(
        email: emailA,
        password: password,
      );
      userA = signUpA.user;
      await authService.signOut();

      final signUpB = await authService.signUpWithEmailPassword(
        email: emailB,
        password: password,
      );
      userB = signUpB.user;
      await authService.signOut();

      // Insert profiles
      await authService.signInWithEmailPassword(
        email: emailA,
        password: password,
      );
      await businessProfileService.insertCurrentBusinessProfile(
        BusinessProfile(id: userA!.id, businessName: 'BizA', sector: 'Retail'),
      );
      await authService.signOut();

      await authService.signInWithEmailPassword(
        email: emailB,
        password: password,
      );
      await businessProfileService.insertCurrentBusinessProfile(
        BusinessProfile(id: userB!.id, businessName: 'BizB', sector: 'Tech'),
      );
      await authService.signOut();
    });

    tearDownAll(() async {
      final users = [userA, userB];
      for (var user in users) {
        if (user == null) continue;
        try {
          await adminClient.from(tableName).delete().eq('id', user.id);
          print('✅ Deleted business profile for ${user.id}');
        } catch (e) {
          print('⚠️ Failed to delete business profile row: $e');
        }
        try {
          await adminClient.auth.admin.deleteUser(user.id);
        } catch (_) {}
      }
    });

    testWidgets('User A cannot read User B business profile', (tester) async {
      await authService.signInWithEmailPassword(
        email: userA!.email!,
        password: 'strongpassword123',
      );

      final result = await Supabase.instance.client
          .from(tableName)
          .select()
          .eq('id', userB!.id)
          .maybeSingle();

      expect(result, isNull);
      await authService.signOut();
    });

    testWidgets('User A cannot update User B business profile', (tester) async {
      await authService.signInWithEmailPassword(
        email: userA!.email!,
        password: 'strongpassword123',
      );

      try {
        await businessProfileService.updateCurrentBusinessProfile(
          BusinessProfile(id: userB!.id, businessName: 'HackedByA'),
          userB!.id,
        );
        fail('Expected update to fail due to RLS');
      } catch (e) {
        print('Caught expected RLS error: $e');
      }

      final res = await adminClient
          .from(tableName)
          .select()
          .eq('id', userB!.id)
          .maybeSingle();
      if (res != null) {
        final profileB = BusinessProfile.fromMap(res);
        expect(profileB.businessName, isNot('HackedByA'));
      }

      await authService.signOut();
    });

    testWidgets('User A cannot upload to User B folder', (tester) async {
      await authService.signInWithEmailPassword(
        email: userA!.email!,
        password: 'strongpassword123',
      );

      final tempDir = await getTemporaryDirectory();
      final fakeFile = File('${tempDir.path}/hack.png');
      await fakeFile.writeAsBytes(List<int>.filled(128, 11));

      final storage = Supabase.instance.client.storage.from(bucketName);
      final path = '${userB!.id}/logo/hack.png';

      try {
        await storage.upload(path, fakeFile);
      } catch (e) {
        print('Caught expected RLS error: $e');
        expect(
          (e as StorageException).message,
          contains('new row violates row-level security policy'),
        );
      }

      final res = await adminClient.storage
          .from(bucketName)
          .list(path: userB!.id);
      expect(res, isEmpty);

      await authService.signOut();
    });
  });
}
