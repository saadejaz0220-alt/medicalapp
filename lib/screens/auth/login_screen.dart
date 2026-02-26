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
                  'Login with your email and 6-digit security code',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Email Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Email Address", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      onChanged: (val) => controller.loginContact.value = val,
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        hintText: 'you@clinic.com',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 6-Digit Code Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("6-Digit Code", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      onChanged: (val) {
                        controller.loginCode.value = val;
                        if (val.length == 6) {
                          controller.doLogin();
                        }
                      },
                      decoration: InputDecoration(
                        counterText: "",
                        hintText: '......',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: const TextStyle(letterSpacing: 10, fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),

                // Login Button
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value ? null : controller.doLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).brightness == Brightness.light 
                            ? Colors.black 
                            : Colors.white,
                        foregroundColor: Theme.of(context).brightness == Brightness.light 
                            ? Colors.white 
                            : Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: controller.isLoading.value
                        ? SizedBox(
                            height: 24, 
                            width: 24, 
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5, 
                              color: Theme.of(context).brightness == Brightness.light 
                                  ? Colors.white 
                                  : Colors.black,
                            ),
                          )
                        : const Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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