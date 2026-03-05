// lib/presentation/screens/account/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'edit_profile_controller.dart';
import '../../../core/theme/app_colors.dart';

class EditProfileScreen extends GetView<EditProfileController> {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header / instruction
              Text(
                'Update your personal information',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 32),

              // Name field
              TextField(
                controller: controller.nameController,
                onChanged: (value) => controller.name.value = value,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'e.g. Amina Khan',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 24),

              // Email field
              TextField(
                controller: controller.emailController,
                onChanged: (value) => controller.email.value = value,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'e.g. amina.khan@example.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),

              // Phone field
              TextField(
                controller: controller.phoneController,
                onChanged: (value) => controller.phone.value = value,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'e.g. +1 234 567 8900',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 48),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.toNamed('/account'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.white 
                              : Colors.black,
                        ),
                      ),

                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(
                          () => ElevatedButton(
                        onPressed: controller.isLoading.value || !controller.isFormValid
                            ? null
                            : controller.saveChanges,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.white
                              : Colors.black,
                          foregroundColor: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.black
                              : Colors.white,
                          side: Theme.of(context).brightness == Brightness.light
                              ? BorderSide(color: Colors.grey.shade300)
                              : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                            : const Text(
                          'Save Changes',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // Security Section
              Text(
                'Security',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                color: Colors.grey.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                ),
                child: ListTile(
                  onTap: controller.goToChangePassword,
                  leading: const Icon(Icons.lock_outline_rounded, color: Colors.blue),
                  title: const Text('Change Password'),
                  subtitle: const Text('Update your numeric security code'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                ),
              ),

              const SizedBox(height: 40),

              // Optional future enhancement area
              // e.g. Change Password, Profile Picture, Phone Number, etc.
            ],
          ),
        ),
      ),
    );
  }
}