// lib/presentation/screens/media/media_library_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/common/embedded_media_player.dart';
import '../../widgets/common/mediacard.dart';
import 'media_controller.dart';

class MediaLibraryScreen extends GetView<MediaController> {
  const MediaLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Media Library')),
      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Center(
              child: Text(
                'Your unlocked homework & guided sessions',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: controller.searchController,
              onChanged: (val) => controller.searchQuery.value = val,
              decoration: InputDecoration(
                hintText: 'Search titles...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).cardColor.withOpacity(0.6),
              ),
            ),
          ),

          // Header (Moved below search and centered)
          

          // Media List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final items = controller.filteredMedia;

              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off_rounded, size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('No matching media found',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      TextButton(onPressed: controller.resetFilters, child: const Text('Clear filters')),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: items.length,
                itemBuilder: (_, i) => MediaCard(
                  media: items[i],
                  tagLabel: 'Post-Session',
                  onPlay: () => controller.playMedia(items[i]),
                ),
              );
            }),
          ),
      ]),
    );
  }
}
