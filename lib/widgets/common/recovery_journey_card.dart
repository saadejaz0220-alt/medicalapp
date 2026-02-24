import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../screens/home/home_controller.dart';

class RecoveryJourneyCard extends StatelessWidget {
  const RecoveryJourneyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      final currentStreak = controller.streak.value;
      final longestStreak = controller.longestStreak.value;
      
      // Streak 0 -> journey_1, Streak 1 -> journey_2, etc. (Cycles every 5)
      int stepIndex = (currentStreak % 5) + 1;
      int sceneNumber = (currentStreak ~/ 5) + 1;

      return Card(
        elevation: 0,
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Your Recovery Journey",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                "Scene $sceneNumber: Building the Zen Garden",
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Large Sequential Image
              Container(
                height: 240,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/journey_$stepIndex.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.blue.withOpacity(0.05),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_outlined, size: 48, color: Colors.blue.withOpacity(0.5)),
                              const SizedBox(height: 12),
                              Text(
                                "Building Scene: Step $stepIndex",
                                style: TextStyle(color: Colors.blue.withOpacity(0.7), fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Progress Indicator for current scene steps
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  bool isCompleted = (index + 1) <= (currentStreak % 5);
                  
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: 40,
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              
              const SizedBox(height: 24),
              
              // Current / Longest streak pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_fire_department, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "$currentStreak Day Streak",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                 "Longest Streak: $longestStreak days",
                 style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ),
      );
    });
  }
}
