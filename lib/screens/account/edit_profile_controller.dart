import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../app/routes/app_routes.dart';
import '../../main.dart';
import '../auth/auth_controller.dart';
import '../home/home_controller.dart';
import 'account_controller.dart';

class EditProfileController extends GetxController {
  final _storage = GetStorage();
  final authController = Get.find<AuthController>();

  // Reactive fields
  final name = ''.obs;
  final email = ''.obs;
  final phone = ''.obs;

  // Text controllers for form fields
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentProfile();
  }

  void _loadCurrentProfile() {
    // Load from global state as initial state
    name.value = loggedInUserData?['name'] ?? 'Patient';
    email.value = loggedInUserData?['email'] ?? '';
    phone.value = loggedInUserData?['phone'] ?? '';

    // Set initial values in text fields
    nameController.text = name.value;
    emailController.text = email.value;
    phoneController.text = phone.value;
  }

  bool get isFormValid {
    final n = name.value.trim();
    final e = email.value.trim();
    return n.isNotEmpty && e.isNotEmpty && e.contains('@') && e.contains('.');
  }

  Future<void> saveChanges() async {
    if (!isFormValid) {
      debugPrint('Profile update validation failed');
      Get.defaultDialog(
        title: 'Invalid Input',
        middleText: 'Please enter a valid name and email address.',
        textConfirm: 'OK',
        confirmTextColor: Colors.white,
        onConfirm: () => Get.back(),
        buttonColor: Colors.redAccent,
      );
      return;
    }

    isLoading.value = true;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('Update profile error: No user logged in');
        throw Exception('No user logged in');
      }

      final updatedName = name.value.trim();
      final updatedEmail = email.value.trim();
      final updatedPhone = phone.value.trim();
      final String currentAuthEmail = user.email ?? '';

      // 1. Update Firebase Auth Email if changed
      if (updatedEmail.toLowerCase() != currentAuthEmail.toLowerCase()) {
        debugPrint('Updating Firebase Auth email from $currentAuthEmail to $updatedEmail');
        
        // Re-authenticate silently as requested using stored password
        final password = loggedInUserData?['password'];
        if (password != null && password.toString().isNotEmpty) {
          debugPrint('Re-authenticating silently for email change...');
          AuthCredential credential = EmailAuthProvider.credential(
            email: currentAuthEmail,
            password: password.toString(),
          );
          await user.reauthenticateWithCredential(credential);
        } else {
          debugPrint('Silent re-auth failed: No password in global state');
          // If we don't have the password, we might still try updateEmail, 
          // but it will likely trigger the requires-recent-login catch block.
        }
        
        await user.updateEmail(updatedEmail);
      }

      // 2. Save to Firestore
      debugPrint('Updating Firestore document for UID: ${user.uid}');
      await FirebaseFirestore.instance.collection('Patients').doc(user.uid).update({
        'name': updatedName,
        'email': updatedEmail,
        'phone': updatedPhone,
      });

      // 3. Update Global State
      Map<String, dynamic> newData = Map.from(loggedInUserData ?? {});
      newData['name'] = updatedName;
      newData['email'] = updatedEmail;
      newData['phone'] = updatedPhone;
      updateLoggedInUserData(newData);

      // 3. Update other controllers
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().username.value = updatedName;
      }
      
      if (Get.isRegistered<AccountController>()) {
        final acc = Get.find<AccountController>();
        acc.name.value = updatedName;
        acc.email.value = updatedEmail;
      }

      Get.back(); // return to Account screen

      Get.snackbar(
        'Profile Updated',
        'Your profile and login email have been updated.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[700],
        colorText: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException during profile update: ${e.code} - ${e.message}');
      if (e.code == 'requires-recent-login') {
        Get.defaultDialog(
          title: 'Security Check',
          middleText: 'For security reasons, please log out and log back in to change your email address.',
          textConfirm: 'OK',
          confirmTextColor: Colors.white,
          onConfirm: () => Get.back(),
          buttonColor: Colors.orange[800],
        );
      } else {
        Get.defaultDialog(
          title: 'Auth Error',
          middleText: e.message ?? 'Failed to update login email.',
          textConfirm: 'OK',
          confirmTextColor: Colors.white,
          onConfirm: () => Get.back(),
        );
      }
    } catch (e) {
      debugPrint('Unexpected error during profile update: $e');
      Get.defaultDialog(
        title: 'Error',
        middleText: 'Failed to save profile: $e',
        textConfirm: 'OK',
        confirmTextColor: Colors.white,
        onConfirm: () => Get.back(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void goToChangePassword() {
    Get.toNamed(AppRoutes.CHANGE_PASSWORD);
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}