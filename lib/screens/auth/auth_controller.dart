import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../app/routes/app_routes.dart';
import '../../main.dart';
import '../../widgets/bottom_nav/Navigation_controller.dart';
import '../account/account_controller.dart';
import '../calendar/calendar_controller.dart';
import '../home/home_controller.dart';
import '../media/media_controller.dart';

class AuthController extends GetxController {
  final storage = GetStorage();
  final RxBool isLoading = false.obs;

  // Login fields (Email and Password)
  final RxString loginContact = ''.obs; // used for email
  final RxString loginCode = ''.obs;    // used for password

  bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;

  @override
  void onInit() {
    super.onInit();
    // Use FirebaseAuth listener for better state management
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _syncUserData(user.uid);
      }
    });
  }

  Future<void> _syncUserData(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('Patients').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        await storage.write('userName', data['name'] ?? 'Patient');
        await storage.write('userEmail', data['email'] ?? '');
        await storage.write('userContact', data['contact'] ?? '');
        updateLoggedInUserData(data);
        // sync other data as needed
      }
    } catch (e) {
      print('Error syncing user data: $e');
    }
  }

  Future<void> requestCode() async {
    Get.snackbar('Coming Soon', 'Password reset will be available soon.');
  }

  Future<void> doLogin() async {
    isLoading.value = true;

    final email = loginContact.value.trim();
    final password = loginCode.value.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Please enter email and password');
      isLoading.value = false;
      return;
    }

    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await _syncUserData(userCredential.user!.uid);
        Get.snackbar('Success', 'Welcome back!', backgroundColor: Colors.green[800], colorText: Colors.white);
        Get.offAllNamed('/');
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', e.message ?? 'Login failed');
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred');
    }

    isLoading.value = false;
  }

  /*
  Future<void> doSignup() async {
    isLoading.value = true;

    final name = signupName.value.trim();
    final email = signupEmail.value.trim();
    final phone = signupPhone.value.trim();

    if (name.isEmpty || email.isEmpty || !email.contains('@') || phone.length < 10) {
      Get.snackbar('Error', 'Please fill all fields correctly');
      isLoading.value = false;
      return;
    }

    await Future.delayed(const Duration(milliseconds: 800));

    // Save user data
    await storage.write('isLoggedIn', true);
    await storage.write('userName', name);
    await storage.write('userEmail', email);
    await storage.write('userPhone', phone);

    Get.snackbar('Account Created', 'Welcome, $name!', backgroundColor: Colors.green[800], colorText: Colors.white);
    Get.offAllNamed('/');

    isLoading.value = false;
  }
  */

  Future<void> logout() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: const Color(0xFF2F2F2F),
        title: const Text('Log Out', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to log out?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      
      // Clear global user data
      updateLoggedInUserData(null);
      
      // Clear persistent storage
      await storage.erase();
      
      // Reset controller-specific sensitive variables
      loginContact.value = '';
      loginCode.value = '';
      
      // Force navigation to login and clear stack
      // This will automatically and safely trigger disposal of all 
      // controllers associated with the previous route/binding.
      Get.offAllNamed(AppRoutes.LOGIN);
      
      Get.snackbar(
        'Logged Out',
        'See you soon!',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}