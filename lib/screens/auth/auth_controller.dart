import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/twilio_service.dart';
import 'dart:math';

import '../../app/routes/app_routes.dart';
import '../../main.dart';

class AuthController extends GetxController {
  final storage = GetStorage();
  final RxBool isLoading = false.obs;

  // Login fields (Email/Phone and 6-Digit Code)
  final RxString loginContact = ''.obs; 
  final RxString loginCode = ''.obs;    
  final RxBool isOtpSent = false.obs;
  final TwilioService _twilioService = TwilioService();

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
        updateLoggedInUserData(data);
      }
    } catch (e) {
      print('Error syncing user data: $e');
    }
  }

  Future<void> sendOtp() async {
    final contact = loginContact.value.trim();
    if (contact.isEmpty) {
      Get.snackbar('Error', 'Please enter a phone number', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    final otp = (100000 + Random().nextInt(900000)).toString();
    // In a real app, you should hash this or store it securely in Firebase/Backend
    // For now, we'll use it to verify locally or against a dummy password in Firebase
    
    final success = await _twilioService.sendSms(
      contact,
      'Your verification code for MedicalApp is $otp',
    );

    if (success) {
      isOtpSent.value = true;
      // Store OTP for verification (Note: In production, verify on server)
      storage.write('temp_otp', otp);
      storage.write('temp_contact', contact);
      Get.snackbar('Success', 'Verification code sent to $contact', backgroundColor: Colors.green[800], colorText: Colors.white);
    } else {
      Get.snackbar('Error', 'Failed to send SMS', snackPosition: SnackPosition.BOTTOM);
    }
    isLoading.value = false;
  }

  Future<void> doLogin() async {
    if (isLoading.value) return;
    
    final contact = loginContact.value.trim();
    final code = loginCode.value.trim();

    if (contact.isEmpty || code.isEmpty || code.length < 6) {
      Get.snackbar('Error', 'Please enter valid credentials', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      final isPhone = !contact.contains('@');
      
      if (isPhone) {
        final savedOtp = storage.read('temp_otp');
        final savedContact = storage.read('temp_contact');
        
        if (contact == savedContact && code == savedOtp) {
          // Attempt to find user by phone in Firestore
          final query = await FirebaseFirestore.instance
              .collection('Patients')
              .where('phone', isEqualTo: contact)
              .limit(1)
              .get();

          if (query.docs.isNotEmpty) {
            final userData = query.docs.first.data();
            final email = userData['email'] as String?;
            
            if (email != null) {
              // Sign in with Firebase using the fixed password/code pattern if applicable
              // Or custom token if using true OTP backend. 
              // For now, we simulate success if the code matches.
              await _syncUserData(query.docs.first.id);
              Get.offAllNamed('/');
            }
          } else {
            Get.snackbar('Error', 'User not found with this phone number', snackPosition: SnackPosition.BOTTOM);
          }
        } else {
          Get.snackbar('Error', 'Invalid verification code', snackPosition: SnackPosition.BOTTOM);
        }
      } else {
        final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: contact,
          password: code,
        );

        if (userCredential.user != null) {
          await _syncUserData(userCredential.user!.uid);
          Get.snackbar('Login Successful', 'Welcome back!', backgroundColor: Colors.green[800], colorText: Colors.white);
          Get.offAllNamed('/');
        }
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Login Error', e.message ?? 'Authentication failed', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred: $e', snackPosition: SnackPosition.BOTTOM);
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