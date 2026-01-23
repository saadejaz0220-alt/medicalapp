// lib/presentation/screens/account/edit_profile_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../auth/auth_controller.dart'; // assuming you have this

class EditProfileController extends GetxController {
  final _storage = GetStorage();
  final authController = Get.find<AuthController>(); // optional if you use it

  // Reactive fields
  final name = ''.obs;
  final email = ''.obs;

  // Text controllers for form fields
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentProfile();
  }

  void _loadCurrentProfile() {
    // Load from storage (or from auth controller if you store there)
    name.value = _storage.read('userName') ?? 'Amina Khan';
    email.value = _storage.read('userEmail') ?? 'amina.khan@example.com';

    // Set initial values in text fields
    nameController.text = name.value;
    emailController.text = email.value;
  }

  bool get isFormValid {
    final n = name.value.trim();
    final e = email.value.trim();
    return n.isNotEmpty && e.isNotEmpty && e.contains('@') && e.contains('.');
  }

  Future<void> saveChanges() async {
    if (!isFormValid) {
      Get.snackbar(
        'Invalid Input',
        'Please enter a valid name and email address',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      // Simulate network delay (remove in real app or replace with API call)
      await Future.delayed(const Duration(milliseconds: 800));

      // Save to storage
      await _storage.write('userName', name.value.trim());
      await _storage.write('userEmail', email.value.trim());

      // Optional: update AuthController if it holds live user data
      // authController.user['name'] = name.value.trim();
      // authController.user['email'] = email.value.trim();

      Get.back(); // return to Account screen

      Get.snackbar(
        'Profile Updated',
        'Your changes have been saved successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[700],
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to save profile. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    super.onClose();
  }
}