import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../widgets/bottom_nav/Navigation_controller.dart';
import '../../widgets/bottom_nav/custom_bottom_nav_bar.dart';
import '../account/account_screen.dart';
import '../auth/auth_controller.dart';
import '../calendar/calendar_screen.dart';
import '../contact/contact_screen.dart';
import '../home/home_screen.dart';
import '../media/media_library_screen.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Obx(() => _screens[Get.find<NavController>().currentIndex.value]),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  static final List<Widget> _screens = [
    HomeScreen(),
    const CalendarScreen(),
    const MediaLibraryScreen(),
    const ContactScreen(),
    const AccountScreen(),
  ];
}