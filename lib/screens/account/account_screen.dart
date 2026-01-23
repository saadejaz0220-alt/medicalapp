// presentation/screens/account/account_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/bottom_nav/custom_bottom_nav_bar.dart';
import '../../widgets/common/themeswitch.dart';
import 'account_controller.dart';
import '../../../core/theme/app_colors.dart';

class AccountScreen extends GetView<AccountController> {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.accent.withOpacity(0.2),
                      child: Text(
                        controller.name.value.isNotEmpty
                            ? controller.name.value[0].toUpperCase()
                            : 'A',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(
                                () => Text(
                              controller.name.value,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Obx(
                                () => Text(
                              controller.email.value,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_rounded),
                      onPressed: controller.goToEditProfile,
                      tooltip: 'Edit Profile',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Preferences Section
            Text(
              'Preferences',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Customize your experience',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Theme Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Theme',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const ThemeSwitch(),
                      ],
                    ),
                    const Divider(height: 32),

                    // Daily Reminder
                    Text(
                      'Daily Reminder',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Obx(
                          () => InkWell(
                        onTap: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay(
                              hour: int.parse(controller.reminderTime.value.split(':')[0]),
                              minute: int.parse(controller.reminderTime.value.split(':')[1]),
                            ),
                            builder: (context, child) {
                              return MediaQuery(
                                data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
                                child: child!,
                              );
                            },
                          );

                          if (picked != null) {
                            final formatted = '${picked.hour.toString().padLeft(2, '0')}:'
                                '${picked.minute.toString().padLeft(2, '0')}';
                            controller.reminderTime.value = formatted;
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                controller.reminderTime.value,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              const Icon(Icons.access_time_rounded),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Back',style: TextStyle(color: Colors.white),)
                    ,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: controller.savePreferences,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Save', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar:
      const CustomBottomNavBar(),
    );
  }
}