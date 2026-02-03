import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../core/theme/theme_controller.dart';
import '../../main.dart';
import '../../app/routes/app_routes.dart';
import '../../services/notification_service.dart';
import '../auth/auth_controller.dart';

class AccountController extends GetxController {
  final ThemeController themeCtrl = Get.find<ThemeController>();
  final AuthController authCtrl = Get.find<AuthController>();

  final RxString name = ''.obs;
  final RxString email = ''.obs;
  final RxString reminderTime = '08:00'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    reminderTime.value = GetStorage().read('daily_reminder') ?? '08:00';
  }

  void _loadUserData() {
    name.value = loggedInUserData?['name'] ?? 'Patient';
    email.value = loggedInUserData?['email'] ?? 'No Email';
  }

  void savePreferences() async {
    // 1. Save to Storage
    await GetStorage().write('daily_reminder', reminderTime.value);
    
    // 2. Schedule Notification
    try {
      final parts = reminderTime.value.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      await NotificationService().scheduleDailyReminder(hour, minute);
      
      Get.snackbar(
        'Saved',
        'Preferences and reminder updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('Error scheduling reminder in AccountController: $e');
      Get.snackbar('Error', 'Failed to schedule reminder: $e');
    }
  }

  void goToEditProfile() {
    Get.toNamed(AppRoutes.EditProfileController);
  }

  void goToChangePassword() {
    Get.toNamed(AppRoutes.CHANGE_PASSWORD);
  }

  void toggleTheme(bool value) {
    themeCtrl.toggleTheme();
  }

  void logout() {
    authCtrl.logout();
  }
}