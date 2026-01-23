// core/theme/theme_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final _storage = GetStorage();
  final RxBool isDark = false.obs;

  ThemeMode get themeMode => isDark.value ? ThemeMode.dark : ThemeMode.light;

  @override
  void onInit() {
    super.onInit();
    isDark.value = _storage.read('isDarkMode') ?? false;
  }

  void toggleTheme() {
    isDark.value = !isDark.value;
    _storage.write('isDarkMode', isDark.value);
    Get.changeThemeMode(themeMode);
    Get.forceAppUpdate(); // helps refresh UI in some cases
  }
}