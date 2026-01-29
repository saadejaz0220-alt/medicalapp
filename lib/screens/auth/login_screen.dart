// presentation/screens/auth/login/login_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import 'auth_controller.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo / Hero
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.health_and_safety_rounded, size: 60, color: Colors.white),
                ),
                const SizedBox(height: 32),

                Text(
                  'Welcome',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your phone/email and the 6-digit code we sent',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text("Phone or Email"),
                const SizedBox(height:5),
                // Contact field
                TextField(
                  onChanged: (val) => controller.loginContact.value = val,
                  decoration: InputDecoration(
                    labelText: 'Phone or Email',
                    hintText: '03xx-xxxxxxx or you@clinic.com',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 15),
                   Text("6-Digit Code"),
                const SizedBox(height:5),
                // Code field
                TextField(
                  onChanged: (val) => controller.loginCode.value = val,
                  decoration: InputDecoration(
                    labelText: '6-Digit Code',
                    hintText: '------',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: controller.requestCode,
                      tooltip: 'Resend code',
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(letterSpacing: 8, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),

                // Login Button
                Obx(
                      () => SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value ? null : controller.doLogin,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2.5))
                          : const Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color:Colors.white )),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Links
                /*Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: controller.requestCode,
                      child: const Text('Resend code'),
                    ),
                    const Text(' • '),
                    TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.SIGNUP),
                      child: const Text('Create account'),
                    ),
                  ],
                ),*/
              ],
            ),
          ),
        ),
      ),
    );
  }
}