// lib/presentation/screens/media/media_controller.dart
import 'package:get/get.dart';

import '../../../data/models/media_item.dart';
import '../../../app/routes/app_routes.dart';
import '../../data/dummy_data/dummy_data.dart';

class MediaController extends GetxController {
  final mediaItems = <MediaItem>[].obs;
  final searchQuery = ''.obs;
  final selectedTag = ''.obs; // empty = all
 /* final openSession = ''.obs;
  final filteredSessions=<Map<String, dynamic>>[].obs;

*/

  final availableTags = [
    '',
    'Breathing',
    'Gratitude',
    'Pain Relief',
    'Sleep',
    'Mindfulness',
    'Focus',
    'Stress',
  ];

  @override
  void onInit() {
    super.onInit();
    loadMedia();
  }

  void loadMedia() {
    mediaItems.value = DummyData.media
        .map((m) => MediaItem(
      id: m['id'],
      title: m['title'],
      tag: m['tag'],
      unlocked: m['unlocked'] ?? true,
      duration: m['duration'],
      thumbnailUrl: m['thumbnail'],
      youtubeId: m['youtubeId'],
      fromSession: m['fromSession'],
      unlockDate: m['unlockDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(m['unlockDate'])
          : null,
    ))
        .where((m) => m.unlocked)
        .toList()
      ..sort((a, b) => (b.unlockDate ?? DateTime(2000)).compareTo(a.unlockDate ?? DateTime(2000)));
  }

  List<MediaItem> get filteredMedia {
    List<MediaItem> list = mediaItems;

    // Search (title OR tag)
    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.value.toLowerCase().trim();
      list = list.where((m) => m.title.toLowerCase().contains(q) || m.tag.toLowerCase().contains(q)).toList();
    }

    // Tag filter
    if (selectedTag.isNotEmpty) {
      list = list.where((m) => m.tag == selectedTag.value).toList();
    }

    return list;
  }

  void playMedia(MediaItem item) {
    Get.toNamed(
      AppRoutes.YoutubePlayer,
      arguments: {'videoId': item.youtubeId, 'title': item.title},
    );
  }

  void resetFilters() {
    searchQuery.value = '';
    selectedTag.value = '';
  }
}
/*

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/media_item.dart';
import '../../../app/routes/app_routes.dart';
import '../../data/dummy_data/dummy_data.dart';

class MediaController extends GetxController {
  final RxList<MediaItem> mediaItems = <MediaItem>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedTag = ''.obs; // empty = all

  final List<String> availableTags = [
    '',
    'Breathing',
    'Gratitude',
    'Pain Relief',
    'Sleep',
    'Mindfulness',
    'Focus',
    'Stress',
  ];

  @override
  void onInit() {
    super.onInit();
    loadMedia();
  }

  void loadMedia() {
    // In real app → API or local storage
    final List<Map<String, dynamic>> raw = DummyData.media;

    mediaItems.value = raw
        .map((m) => MediaItem(
      id: m['id'],
      title: m['title'],
      tag: m['tag'],
      unlocked: m['unlocked'] ?? true, // most are unlocked in demo
      duration: m['duration'],
      thumbnailUrl: m['thumbnail'],
      youtubeId: m['youtubeId'],
      fromSession: m['fromSession'],
      unlockDate: m['unlockDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(m['unlockDate'])
          : null,
    ))
        .where((m) => m.unlocked)
        .toList();

    mediaItems.sort((a, b) => (b.unlockDate ?? DateTime(2000)).compareTo(a.unlockDate ?? DateTime(2000)));
  }

  List<MediaItem> get filteredMedia {
    List<MediaItem> list = mediaItems;

    // Search
    if (searchQuery.value.trim().isNotEmpty) {
      final query = searchQuery.value.toLowerCase().trim();
      list = list.where((m) {
        return m.title.toLowerCase().contains(query) ||
            m.tag.toLowerCase().contains(query);
      }).toList();
    }

    // Tag filter
    if (selectedTag.value.isNotEmpty) {
      list = list.where((m) => m.tag == selectedTag.value).toList();
    }

    return list;
  }

  bool get hasNoResults => filteredMedia.isEmpty && mediaItems.isNotEmpty;

  void playMedia(MediaItem item) {
    Get.snackbar(
      'Playing',
      '${item.title} (${item.duration}m)',
      duration: const Duration(seconds: 4),
      mainButton: TextButton(
        onPressed: () {
          AppRoutes.YoutubePlayer;
          // Here you would open real player
          Get.toNamed(
            '/youtube-player',
            arguments: {'videoId': item.youtubeId, 'title': item.title},
          );
        },
        child: const Text('Open Player'),
      ),
    );
  }

  void resetFilters() {
    searchQuery.value = '';
    selectedTag.value = '';
  }
}
*/
