import 'package:flutter/material.dart';
import 'package:homebased_project/data/user_profile_repository.dart';
import 'package:homebased_project/data/business_profile_repository.dart';
import 'package:homebased_project/backend/user_profile_api/user_profile_model.dart';
import 'package:homebased_project/backend/business_profile_api/business_profile_model.dart';

class ProfileNotifier extends ChangeNotifier {
  ProfileNotifier(this.userRepo, this.businessRepo);

  final UserProfileRepository userRepo;
  final BusinessProfileRepository businessRepo;

  // --- User state ---
  UserProfile? userProfile;
  UserProfile? editingUserProfile;
  bool userLoading = true;
  bool userEditing = false;

  // --- Business state ---
  BusinessProfile? businessProfile;
  BusinessProfile? editingBusinessProfile;
  bool businessLoading = true;
  bool businessEditing = false;

  // --- Initialization ---
  Future<void> loadAll() async {
    userLoading = true;
    businessLoading = true;
    notifyListeners();

    userProfile = await userRepo.getUserProfile();
    businessProfile = await businessRepo.getBusiness();

    userLoading = false;
    businessLoading = false;
    notifyListeners();
  }

  // --- Editing actions ---
  void startEditingUser() {
    editingUserProfile = userProfile?.copyWith();
    userEditing = true;
    notifyListeners();
  }

  void startEditingBusiness() {
    editingBusinessProfile = businessProfile?.copyWith();
    businessEditing = true;
    notifyListeners();
  }

  void cancelUserEdit() {
    editingUserProfile = null;
    userEditing = false;
    notifyListeners();
  }

  void cancelBusinessEdit() {
    editingBusinessProfile = null;
    businessEditing = false;
    notifyListeners();
  }

  // --- Save actions ---
  Future<void> saveUser() async {
    if (editingUserProfile != null) {
      await userRepo.updateUser(editingUserProfile!);
      userProfile = editingUserProfile;
      editingUserProfile = null;
      userEditing = false;
      notifyListeners();
    }
  }

  Future<void> saveBusiness() async {
    if (editingBusinessProfile != null) {
      await businessRepo.updateBusiness(editingBusinessProfile!);
      businessProfile = editingBusinessProfile;
      editingBusinessProfile = null;
      businessEditing = false;
      notifyListeners();
    }
  }
}
