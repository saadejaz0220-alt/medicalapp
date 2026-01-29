import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';


class SimpleProgressCard extends StatelessWidget {
  const SimpleProgressCard({super.key});

  RxInt get completedSessions => 10.obs;
  RxInt get daysMeditated => 15.obs;
  RxInt get longestStreak => 7.obs;


  @override
  Widget build(BuildContext context) {

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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _simpleItem(completedSessions, "clinical Sessions \nCompleted", Icons.medical_services),
                _simpleItem(daysMeditated, " Days\n meditated \nthis month", Icons.self_improvement),
                _simpleItem(longestStreak, "Longest streak\n(days)", Icons.local_fire_department, isStreak: true),
              ],
            ),
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
        Obx(() => Text(
          value.value.toString(),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        )),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }
}
