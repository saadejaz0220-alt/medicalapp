import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';

import '../../screens/home/home_controller.dart';

class ImageGalleryCard extends GetView<HomeController> {
  const ImageGalleryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Your Recovery Journey\nEarn a piece every days",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Obx(() => GridView.builder(
                shrinkWrap: true, // Allows GridView to work inside ListView
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 4, // 3 images per row
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: controller.galleryImages.length + 1, // +1 for the "Add" button
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // The "Add Image" slot
                    return GestureDetector(
                      onTap: () => controller.addImage(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                        ),
                        child: (const Icon(Icons.add, size: 12)),
                      ),
                    );
                  }

                  // The actual images
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      controller.galleryImages[index - 1],
                      fit: BoxFit.cover,
                    ),
                  );
                },
              )),
            ],
          ),
        ),
      ),
    );
  }
}