import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../app/routes/app_routes.dart';

class AuthController extends GetxController {
  final storage = GetStorage();

  final RxBool isLoading = false.obs;

  // Login fields
  final RxString loginContact = ''.obs;
  final RxString loginCode = ''.obs;

  // Signup fields
  final RxString signupName = ''.obs;
  final RxString signupEmail = ''.obs;
  final RxString signupPhone = ''.obs;

  bool get isLoggedIn => storage.read('isLoggedIn') == true;

  @override
  void onInit() {
    super.onInit();
    // Optional: auto redirect if already "logged in"
    if (isLoggedIn) {
      Future.delayed(Duration.zero, () => Get.offAllNamed(AppRoutes.HOME));
    }
  }

  Future<void> requestCode() async {
    final contact = loginContact.value.trim();
    if (contact.isEmpty) {
      Get.snackbar('Error', 'Please enter phone or email');
      return;
    }

    // In real app → call API to send OTP
    // Here: mock alert with random code (like original)
    final mockCode = (100000 + DateTime.now().millisecond % 900000).toString();
    Get.snackbar(
      'Mock OTP Sent',
      'Your code is: $mockCode\n(sent to $contact)',
      duration: const Duration(seconds: 5),
    );

    // For demo: auto-fill code field with 123456
    loginCode.value = '123456';
  }

  Future<void> doLogin() async {
    isLoading.value = true;

    final contact = loginContact.value.trim();
    final code = loginCode.value.trim();

    await Future.delayed(const Duration(milliseconds: 800)); // fake delay

    // Demo logic: accept "123456" or any non-empty contact
    if (code == '123456' && contact.isNotEmpty) {
      // Save "logged in" state
      await storage.write('isLoggedIn', true);
      await storage.write('userContact', contact);

      // Optional: save mock user name
      String name = contact.split('@').first.split('.').map((e) => e.capitalizeFirst).join(' ');
      if (name.isEmpty) name = 'Patient';
      await storage.write('userName', name);

      Get.snackbar('Success', 'Welcome back!', backgroundColor: Colors.green[800], colorText: Colors.white);
      Get.offAllNamed(AppRoutes.HOME);
    } else {
      Get.snackbar('Error', 'Invalid code or contact');
    }

    isLoading.value = false;
  }

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
    Get.offAllNamed(AppRoutes.HOME);

    isLoading.value = false;
  }

  Future<void> logout() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
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
      await storage.erase(); // or selective remove
      Get.offAllNamed(AppRoutes.LOGIN);
      Get.snackbar('Logged Out', 'See you soon!');
    }
  }
}