// lib/presentation/screens/media/media_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/media_item.dart';
import '../../../app/routes/app_routes.dart';
import '../../data/dummy_data/dummy_data.dart';
import '../../widgets/common/embedded_media_player.dart';

class MediaController extends GetxController {
  final mediaItems = <MediaItem>[].obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadMedia();
  }

  void loadMedia() {
    mediaItems.value = DummyData.media
        .map((m) {
          final data = Map<String, dynamic>.from(m);
          return MediaItem.fromFirestore(data, data['id'].toString());
        })
        .toList();
  }

  List<MediaItem> get filteredMedia {
    List<MediaItem> list = mediaItems;

    // Search (title)
    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.value.toLowerCase().trim();
      list = list.where((m) => m.title.toLowerCase().contains(q)).toList();
    }

    return list;
  }

  void playMedia(MediaItem item) {
    if (Get.isDialogOpen == true) return;
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: EmbeddedMediaPlayer(
          key: ValueKey(item.url),
          media: item,
          onProgressUpdate: (percentage) {
            // Update progress in local state
            final index = mediaItems.indexWhere((m) => m.id == item.id);
            if (index != -1) {
              mediaItems[index] = mediaItems[index].copyWith(progress: percentage);
              mediaItems.refresh();
            }
          },
          onClose: () => Get.back(),
        ),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black54,
    );
  }

  void resetFilters() {
    searchQuery.value = '';
  }
}
