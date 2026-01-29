import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../screens/home/home_controller.dart';

class JourneyProgressCard extends GetView<HomeController> {
  const JourneyProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Current Journey: ${controller.currentJourney.value}",
            style: const TextStyle(color: Colors.blue,fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          // Progress bar representing journey completion
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0.6, // Replace with dynamic logic from controller
              backgroundColor: Colors.grey[300],
              color: Colors.blueAccent,
              minHeight: 8,
            ),
          ),
        ],
      ),
    ));
  }
}

class CompletedSessionsList extends GetView<HomeController> {
  const CompletedSessionsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Completed Clinic Sessions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {},
              child: const Text("See more →",
              style: TextStyle(color: Colors.white),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
              ) ),
          ],
        ),
        const SizedBox(height: 8),
        ...controller.completedSessions.map((session) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              session['title'] ?? 'Session',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text("Completed on ${session['date'] ?? 'N/A'}"),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Done",
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
        )),
      ],
    ));
  }
}
