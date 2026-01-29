import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../core/theme/theme_controller.dart';
import '../../data/dummy_data/dummy_data.dart';

class AccountController extends GetxController {
  final ThemeController themeCtrl = Get.find<ThemeController>();

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
    name.value = DummyData.user['name'] ?? 'Amina Khan';
    email.value = DummyData.user['email'] ?? 'amina.khan@example.com';
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
}