import 'package:flutter/material.dart';
import 'package:homebased_project/backend/user_profile_api/user_profile_service.dart';
import 'package:homebased_project/backend/business_profile_api/business_profile_service.dart';
import 'package:homebased_project/data/business_profile_repository.dart';
import 'package:homebased_project/data/profile_notifier.dart';
import 'package:homebased_project/data/user_profile_repository.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileNotifier(
        UserProfileRepository(UserProfileService()),
        BusinessProfileRepository(BusinessProfileService()),
      )..loadAll(),
      child: Consumer<ProfileNotifier>(
        builder: (context, notifier, _) {
          // --- Loading states ---
          final userLoading = notifier.userLoading;
          final businessLoading = notifier.businessLoading;

          return Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // --- User Avatar & Name ---
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: userLoading
                        ? Center(child: CircularProgressIndicator())
                        : Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                radius: 80,
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage:
                                    notifier.userProfile?.avatarUrl != null &&
                                        notifier.userProfile!.avatarUrl!
                                            .startsWith('http')
                                    ? NetworkImage(
                                        notifier.userProfile!.avatarUrl!,
                                      )
                                    : const AssetImage(
                                        'assets/defaultUser.png',
                                      ),
                              ),
                              if (notifier.userEditing)
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {},
                                ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 12),
                  userLoading
                      ? const CircularProgressIndicator()
                      : Text(
                          notifier.userProfile?.username ?? "Guest",
                          style: const TextStyle(fontSize: 24),
                        ),

                  const SizedBox(height: 24),
                  // --- Edit / Form sections would go here ---
                  // For example, TextFormFields bound to notifier.editingBusinessProfile
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
