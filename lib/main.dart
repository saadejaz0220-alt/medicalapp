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
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';

Map<String, dynamic>? loggedInUserData;

void updateLoggedInUserData(Map<String, dynamic>? data) {
  loggedInUserData = data;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService().init();

  final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;

  if (isLoggedIn) {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc = await FirebaseFirestore.instance.collection('Patients').doc(uid).get();
      if (doc.exists) {
        loggedInUserData = doc.data();
      }
    } catch (e) {
      debugPrint('Error fetching persistent user data: $e');
    }
  }

  // TODO: Remove this in production. Forces logout to verify initial route.
  // await GetStorage().erase(); 
  

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.put(ThemeController());

    return GetMaterialApp(
      title: 'Patient App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeCtrl.themeMode,
      initialRoute: isLoggedIn ? '/' : AppRoutes.LOGIN,
      getPages: AppPages.routes,
      initialBinding: InitialBinding(),
    );
  }
}