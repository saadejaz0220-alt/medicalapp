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
      
      // We show 9 slots. 
      // If currentStreak <= 9, we show 1 to 9.
      // If currentStreak > 9, we show (currentStreak - 8) to currentStreak.
      int startStreak = currentStreak <= 9 ? 1 : (currentStreak - 8);
      
      return Card(
        elevation: 0,
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Your Recovery Journey\nEarn a reward every day",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              // 3x3 Grid
              SizedBox(
                height: 200,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    final streakNumber = startStreak + index;
                    bool isEarned = streakNumber <= currentStreak;
                    
                    // Looping assets: 1, 6, 11... use scene_1.png
                    final assetIndex = ((streakNumber - 1) % 5) + 1;
                    
                    return Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: isEarned ? null : const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(12),
                            image: isEarned 
                              ? DecorationImage(
                                  image: AssetImage('assets/images/scene_$assetIndex.png'),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          ),
                        ),
                        if (isEarned)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                "$streakNumber",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Piece count pill - Current / Longest
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    "$currentStreak / $longestStreak",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
