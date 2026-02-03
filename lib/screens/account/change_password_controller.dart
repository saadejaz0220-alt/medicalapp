import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../main.dart';

class ChangePasswordController extends GetxController {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final obscureOld = true.obs;
  final obscureNew = true.obs;
  final obscureConfirm = true.obs;

  bool _isValid6Digit(String pass) {
    return pass.length == 6 && int.tryParse(pass) != null;
  }

  Future<void> changePassword() async {
    final oldPass = oldPasswordController.text.trim();
    final newPass = newPasswordController.text.trim();
    final confirmPass = confirmPasswordController.text.trim();

    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      debugPrint('Password change failed: Empty fields');
      Get.defaultDialog(
        title: 'Empty Fields',
        middleText: 'Please fill in all the required fields.',
        textConfirm: 'OK',
        confirmTextColor: Colors.white,
        onConfirm: () => Get.back(),
      );
      return;
    }

    if (!_isValid6Digit(oldPass)) {
      debugPrint('Password change failed: Current password not 6 digits');
      Get.defaultDialog(
        title: 'Invalid Current Password',
        middleText: 'Current password must be exactly 6 digits.',
        textConfirm: 'OK',
        confirmTextColor: Colors.white,
        onConfirm: () => Get.back(),
      );
      return;
    }

    if (newPass != confirmPass) {
      debugPrint('Password change failed: Mismatch');
      Get.defaultDialog(
        title: 'Mismatch',
        middleText: 'New passwords do not match. Please try again.',
        textConfirm: 'OK',
        confirmTextColor: Colors.white,
        onConfirm: () => Get.back(),
      );
      return;
    }

    if (!_isValid6Digit(newPass)) {
      debugPrint('Password change failed: New password not 6 digits');
      Get.defaultDialog(
        title: 'Weak Password',
        middleText: 'New password must be exactly 6 digits.',
        textConfirm: 'OK',
        confirmTextColor: Colors.white,
        onConfirm: () => Get.back(),
      );
      return;
    }

    isLoading.value = true;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('Password change error: No user logged in');
        throw Exception('No user logged in');
      }

      // 1. Re-authenticate user (required by Firebase for password change)
      final email = user.email;
      if (email == null) throw Exception('User email not found');

      debugPrint('Re-authenticating user for password change...');
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: oldPass,
      );

      await user.reauthenticateWithCredential(credential);

      // 2. Update password
      debugPrint('Updating password in Firebase Auth...');
      await user.updatePassword(newPass);

      // 3. Update global state with the new password for future silent re-auths
      if (loggedInUserData != null) {
        final updatedData = Map<String, dynamic>.from(loggedInUserData!);
        updatedData['password'] = newPass;
        updateLoggedInUserData(updatedData);
      }

      Get.back(); // Close screen
      Get.snackbar(
        'Success',
        'Password updated successfully',
        backgroundColor: Colors.green[800],
        colorText: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException during password change: ${e.code} - ${e.message}');
      Get.defaultDialog(
        title: 'Auth Error',
        middleText: e.message ?? 'Failed to update password.',
        textConfirm: 'OK',
        confirmTextColor: Colors.white,
        onConfirm: () => Get.back(),
      );
    } catch (e) {
      debugPrint('Unexpected error during password change: $e');
      Get.defaultDialog(
        title: 'Error',
        middleText: 'An unexpected error occurred: $e',
        textConfirm: 'OK',
        confirmTextColor: Colors.white,
        onConfirm: () => Get.back(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
