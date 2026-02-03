import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../screens/home/home_controller.dart';

class SimpleProgressCard extends StatelessWidget {
  const SimpleProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your Progress This Month",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _simpleItem(controller.clinicalSessionsThisMonth, "clinical Sessions \nCompleted", Icons.medical_services),
                _simpleItem(controller.daysActiveThisMonth, " Days\n meditated \nthis month", Icons.self_improvement),
                _simpleItem(controller.longestStreak, "Longest streak\n(days)", Icons.local_fire_department, isStreak: true),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _simpleItem(RxInt value, String label, IconData icon, {bool isStreak = false}) {
    return Column(
      children: [
        Icon(icon, size: 32, color: isStreak ? Colors.orange : Colors.blue),
        const SizedBox(height: 8),
        Text(
          value.value.toString(),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13), textAlign: TextAlign.center),
      ],
    );
  }
}
