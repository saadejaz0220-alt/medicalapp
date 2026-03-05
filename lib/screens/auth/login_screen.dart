import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

import '../../app/routes/app_routes.dart';
import 'auth_controller.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Default Pinput theme
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
      borderRadius: BorderRadius.circular(12),
    );

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
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.health_and_safety_rounded, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 24),

                Text(
                  'Welcome',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Obx(() => Text(
                  controller.loginContact.value.isNotEmpty && !controller.loginContact.value.contains('@')
                      ? 'Login with your phone number'
                      : 'Login with your email and code',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                )),
                const SizedBox(height: 32),
                
                // Email/Phone Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Email or Phone Number", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      onChanged: (val) {
                        controller.loginContact.value = val;
                        if (controller.isOtpSent.value) {
                          controller.isOtpSent.value = false;
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Email or Phone',
                        hintText: 'you@clinic.com or +1234567890',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.contact_mail_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email, AutofillHints.telephoneNumber],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Main Action Button (Send Code or Login)
                Obx(() {
                  final contact = controller.loginContact.value;
                  final isPhone = contact.isNotEmpty && !contact.contains('@');
                  final otpSent = controller.isOtpSent.value;
                  final isLoading = controller.isLoading.value;

                  // If it's a phone number and OTP hasn't been sent yet, show "Text me a code" as the main button
                  if (isPhone && !otpSent) {
                    return SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : controller.sendOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Text me a code to login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    );
                  }

                  // Otherwise show the login button at the bottom (handled below)
                  return const SizedBox.shrink();
                }),

                // 6-Digit Code Field (Appears after text is sent or if it's an email)
                Obx(() {
                  final contact = controller.loginContact.value;
                  final isPhone = contact.isNotEmpty && !contact.contains('@');
                  final showCodeField = !isPhone || controller.isOtpSent.value;
                  
                  if (!showCodeField) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("6-Digit Code", style: TextStyle(fontWeight: FontWeight.bold)),
                          if (isPhone)
                            TextButton(
                              onPressed: controller.isLoading.value ? null : controller.sendOtp,
                              child: const Text("Resend"),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Pinput(
                          length: 6,
                          defaultPinTheme: defaultPinTheme,
                          focusedPinTheme: focusedPinTheme,
                          onChanged: (val) => controller.loginCode.value = val,
                          onCompleted: (pin) {
                            controller.loginCode.value = pin;
                            controller.doLogin();
                          },
                          keyboardType: TextInputType.number,
                          autofillHints: const [AutofillHints.oneTimeCode],
                         // smsCodeMatcher: PinputConstants.defaultSmsCodeMatcher,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Final Login Button (Only visible when code field is shown)
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value ? null : controller.doLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
                            foregroundColor: Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: controller.isLoading.value
                              ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.black))
                              : const Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
