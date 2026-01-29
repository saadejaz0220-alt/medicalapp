import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../screens/home/home_controller.dart';

// 1. NOW PLAYING DIALOG
class SessionPlayDialog extends StatelessWidget {
  final String title;
  final VoidCallback onComplete;

  const SessionPlayDialog({super.key, required this.title, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(alignment: Alignment.topRight, child: IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back())),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_circle_fill, color: Colors.blue),
                SizedBox(width: 8),
                Text("Now playing • 15 minutes", style: TextStyle(color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onComplete,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, minimumSize: const Size(double.infinity, 45)),
              child: const Text("Mark as Complete", style: TextStyle(color: Colors.white)),
            ),
            TextButton(onPressed: () => Get.back(), child: const Text("Close", style: TextStyle(color: Colors.grey))),
          ],
        ),
      ),
    );
  }
}

// 2. IMAGE GRID CARD
class ImageGridCard extends GetView<HomeController> {
  const ImageGridCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Journey Gallery", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Obx(() => GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
              itemCount: controller.galleryImages.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return GestureDetector(
                    onTap: controller.addImage,
                    child: Container(color: Colors.grey[200], child: const Icon(Icons.add_a_photo)),
                  );
                }
                return Image.network(controller.galleryImages[index - 1], fit: BoxFit.cover);
              },
            )),
          ],
        ),
      ),
    );
  }
}