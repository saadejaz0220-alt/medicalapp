import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../core/theme/theme_controller.dart';
import '../auth/auth_controller.dart';
import '../../data/dummy_data/dummy_data.dart';

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
    name.value = GetStorage().read('userName') ?? 'Patient';
    email.value = GetStorage().read('userEmail') ?? 'No Email';
  }

  void savePreferences() {
    GetStorage().write('daily_reminder', reminderTime.value);
    Get.snackbar(
      'Saved',
      'Preferences updated successfully',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void goToEditProfile() {
    Get.toNamed('/edit-profile'); // you'll create this next if needed
  }

  void toggleTheme(bool value) {
    themeCtrl.toggleTheme(); // already handles persistence & UI update
  }

  void logout() {
    authCtrl.logout();
  }
}