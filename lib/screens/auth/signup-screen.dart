// presentation/screens/auth/signup/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'auth_controller.dart';


class SignupScreen extends GetView<AuthController> {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Get Started',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your details to create your account',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 40),

            TextField(
              onChanged: (val) => controller.signupName.value = val,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),

            TextField(
              onChanged: (val) => controller.signupEmail.value = val,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),

            TextField(
              onChanged: (val) => controller.signupPhone.value = val,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 40),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.toNamed('/login'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(
                        () => ElevatedButton(
                      onPressed: controller.isLoading.value ? null : controller.doSignup,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2.5))
                          : const Text('Create', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}