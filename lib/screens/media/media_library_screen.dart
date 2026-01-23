// lib/presentation/screens/media/media_library_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/common/gradient_button.dart';
import '../../widgets/bottom_nav/custom_bottom_nav_bar.dart';
import 'media_controller.dart';

class MediaLibraryScreen extends GetView<MediaController> {
  const MediaLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Media Library')),
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Your unlocked homework & guided sessions',
              style: Theme
                  .of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),

          // Search + Filter
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    onChanged: (val) => controller.searchQuery.value = val,
                    decoration: InputDecoration(
                      hintText: 'Search titles or tags...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Theme
                          .of(context)
                          .cardColor
                          .withOpacity(0.6),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Obx(
                        () =>
                        DropdownButtonFormField<String>(
                          value: controller.selectedTag.value.isEmpty
                              ? null
                              : controller.selectedTag.value,
                          hint: const Text('All Tags'),
                          isExpanded: true,
                          items: controller.availableTags
                              .map((tag) =>
                              DropdownMenuItem(value: tag.isEmpty
                                  ? null
                                  : tag,
                                  child: Text(tag.isEmpty ? 'All Tags' : tag)))
                              .toList(),
                          onChanged: (val) =>
                          controller.selectedTag.value = val ?? '',
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ),

          // Media List
          Expanded(
            child: Obx(() {
              final items = controller.filteredMedia;

              //if (controller.mediaItems.isEmpty) return _buildEmptyState();

              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off_rounded, size: 80,
                          color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('No matching media found',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight
                              .w500)),
                      const SizedBox(height: 8),
                      TextButton(onPressed: controller.resetFilters,
                          child: const Text('Clear filters')),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                itemCount: items.length,
                itemBuilder: (_, i) =>
                    MediaCard(
                      media: items[i],
                      onPlay: () => controller.playMedia(items[i]),
                      onTap: () {},
                    ),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

/*Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.library_music_outlined, size: 100, color: Colors.grey),
            const SizedBox(height: 24),
            const Text('No media yet', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
              'Complete clinic sessions to unlock guided homework and meditations',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => Get.toNamed('/home'),
              icon: const Icon(Icons.home, color: Colors.white),
              label: const Text('Go to Home', style: TextStyle(color: Colors.white)),
              style: OutlinedButton.styleFrom(backgroundColor: Theme.of(Get.context!).colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}*/


/*
// presentation/screens/media/media_library_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/bottom_nav/custom_bottom_nav_bar.dart';
import '../../widgets/common/gradient_button.dart';
import 'media_controller.dart';
import '../../../core/theme/app_colors.dart'; // your colors

class MediaLibraryScreen extends GetView<MediaController> {
  const MediaLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Library'),
      ),
      body: Column(
        children: [
          // Search + Filter Row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    onChanged: (val) => controller.searchQuery.value = val,
                    decoration: InputDecoration(
                      hintText: 'Search titles or tags...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Theme
                          .of(context)
                          .cardColor
                          .withOpacity(0.6),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Obx(
                        () =>
                        DropdownButtonFormField<String>(
                          value: controller.selectedTag.value.isEmpty
                              ? null
                              : controller.selectedTag.value,
                          hint: const Text('All Tags'),
                          isExpanded: true,
                          items: controller.availableTags.map((tag) {
                            return DropdownMenuItem(
                              value: tag.isEmpty ? null : tag,
                              child: Text(tag.isEmpty ? 'All Tags' : tag),
                            );
                          }).toList(),
                          onChanged: (val) {
                            controller.selectedTag.value = val ?? '';
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Obx(() {
              final items = controller.filteredMedia;

              if (controller.mediaItems.isEmpty) {
                //return _buildEmptyState();
              }

              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off_rounded, size: 80,
                          color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No matching media found',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight
                            .w500),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: controller.resetFilters,
                        child: const Text('Clear filters'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return MediaCard(
                    media: item,
                    onTap: () => controller.playMedia(item), onPlay: () {  },
                  );
                },
              );
            }),
          ),
        ],
      ),
        bottomNavigationBar:
        const CustomBottomNavBar(),
    );

  }
}

  */
/*Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.library_music_outlined, size: 100, color: Colors.grey),
            const SizedBox(height: 24),
            const Text(
              'No media yet',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Complete clinic sessions to unlock guided homework and meditations',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => Get.toNamed('/home'),
              icon: const Icon(Icons.home,color: Colors.white,),
              label: const Text('Go to Home',style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }*/
}


