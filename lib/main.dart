// main.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'package:medicalapp/screens/auth/auth_controller.dart';
import 'package:medicalapp/widgets/bottom_nav/Navigation_controller.dart';

import 'app/bindings/initial_Bindings.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'core/theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.put(ThemeController());

    return GetMaterialApp(
      title: 'Patient App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      darkTheme: ThemeData.light(),
      themeMode: themeCtrl.themeMode,
      initialRoute: AppRoutes.LOGIN,
      getPages: AppPages.routes,
      initialBinding: InitialBinding(),
    );
  }
}