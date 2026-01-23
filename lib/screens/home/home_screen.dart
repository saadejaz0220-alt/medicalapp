import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';

import '../../app/routes/app_routes.dart';
import '../../widgets/bottom_nav/custom_bottom_nav_bar.dart';
import '../../widgets/common/session_card.dart';
import 'home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient App"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.toNamed(AppRoutes.ACCOUNT),
          ),
        ],
      ),
      body: Obx(() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Greeting + Streak
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Good Day", style: Get.textTheme.bodySmall),
                  Text(
                    controller.username.value,
                    style: Get.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                children: [
                  Text("Streak", style: Get.textTheme.bodySmall),
                  Text(
                    "${controller.streak.value}",
                    style: TextStyle(
                      fontSize: 22,
                     // color: Get.theme.colorScheme.primary,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Next', 'Upcoming', 'Past', 'All']
                  .map((t) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(t),
                  selected: controller.selectedTab.value ==
                      t.toLowerCase(),
                  onSelected: (_) =>
                      controller.changeTab(t.toLowerCase()),
                ),
              ))
                  .toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Sessions list
          ...controller.filteredSessions.map((s) => SessionCard(
            session: s,
            onTap: () => controller.openSession(s['id']),
          )),
        ],
      )),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}