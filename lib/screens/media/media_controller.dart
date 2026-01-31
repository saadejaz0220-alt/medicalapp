// lib/presentation/screens/media/media_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/media_item.dart';
import '../../../app/routes/app_routes.dart';
import '../../data/dummy_data/dummy_data.dart';
import '../../widgets/common/embedded_media_player.dart';

class MediaController extends GetxController {
  final mediaItems = <MediaItem>[].obs;
  final searchQuery = ''.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllMediaHistory();
  }

  Future<void> fetchAllMediaHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    isLoading.value = true;
    try {
      // 1. Get ALL history records for this user
      final historyQuery = await FirebaseFirestore.instance
          .collection('history')
          .where('patientId', isEqualTo: user.uid)
          .orderBy('date', descending: true)
          .get();

      List<MediaItem> allMedias = [];
      Set<String> processedSessionIds = {};

      for (var doc in historyQuery.docs) {
        final data = doc.data();
        final sessionId = data['sessionId'];
        
        if (sessionId != null && sessionId is String && sessionId.isNotEmpty) {
          if (processedSessionIds.contains(sessionId)) continue;
          processedSessionIds.add(sessionId);

          // 2. Fetch the session doc
          final visitDoc = await FirebaseFirestore.instance.collection('Visits').doc(sessionId).get();
          if (visitDoc.exists) {
            final visitData = visitDoc.data()!;
            final String sessionTitle = visitData['visitName'] ?? 'Untitled Session';
            final String visitId = visitData['visitId'] ?? sessionId;
            final List<dynamic>? postSessionWorkout = visitData['postSessionWorkout'];

            if (postSessionWorkout != null && postSessionWorkout.isNotEmpty) {
              // 3. Fetch each media doc
              for (var workout in postSessionWorkout) {
                final mediaId = workout['mediaId'];
                if (mediaId != null) {
                  final mediaDoc = await FirebaseFirestore.instance.collection('Media').doc(mediaId.toString()).get();
                  if (mediaDoc.exists) {
                    final mediaData = Map<String, dynamic>.from(mediaDoc.data()!);
                    mediaData['fromSession'] = sessionTitle;
                    mediaData['fromSessionId'] = visitId;
                    
                    final item = MediaItem.fromFirestore(mediaData, mediaDoc.id);
                    // Deduplicate media items: show each media only once in the entire library
                    if (!allMedias.any((m) => m.id == item.id)) {
                      allMedias.add(item);
                    }
                  }
                }
              }
            }
          }
        }
      }

      mediaItems.assignAll(allMedias);
    } catch (e) {
      print('Error fetching full media history: $e');
    } finally {
      isLoading.value = false;
    }
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
