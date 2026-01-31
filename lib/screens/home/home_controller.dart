import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../app/routes/app_routes.dart';
import '../../data/dummy_data/dummy_data.dart';
import '../../data/models/media_item.dart';
import '../../widgets/common/embedded_media_player.dart';

class HomeController extends GetxController {
  var selectedTab = 'next'.obs;
  var streak = 7.obs;
  var username = 'Amna khan'.obs;
  var completedSessions = <Map<String, dynamic>>[].obs;
  var currentJourney = 'Mind–Body \nRenewal Journey'.obs;
  var currentSession = <String, dynamic>{}.obs;

  var postSessionMedias = <MediaItem>[].obs;
  var isLoadingMedias = false.obs;

  var galleryImages = <String>[].obs;
  void addImage() {
    galleryImages.add("https://via.placeholder.com/150");
    galleryImages.refresh();
  }

  @override
  void onInit() {
    super.onInit();
    // load from storage if needed
    username.value = GetStorage().read('userName') ?? 'Patient';
    fetchPostSessionWorkouts();
  }

  Future<void> fetchPostSessionWorkouts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    isLoadingMedias.value = true;
    try {
      // 1. Get latest history record for this patient with a sessionId
      final historyQuery = await FirebaseFirestore.instance
          .collection('history')
          .where('patientId', isEqualTo: user.uid)
          .orderBy('date', descending: true)
          .get();

      String? sessionId;
      for (var doc in historyQuery.docs) {
        final data = doc.data();
        final sId = data['sessionId'];
        if (sId != null && sId is String && sId.isNotEmpty) {
          sessionId = sId;
          break;
        }
      }

      if (sessionId == null) {
        isLoadingMedias.value = false;
        return;
      }

      // 2. Get the session doc from 'Visits' collection
      final visitDoc = await FirebaseFirestore.instance.collection('Visits').doc(sessionId).get();
      if (!visitDoc.exists) {
        isLoadingMedias.value = false;
        return;
      }

      final visitData = visitDoc.data()!;
      final String sessionTitle = visitData['visitName'] ?? 'Untitled Session';
      final String visitId = visitData['visitId'] ?? sessionId;
      final List<dynamic>? postSessionWorkout = visitData['postSessionWorkout'];

      if (postSessionWorkout == null || postSessionWorkout.isEmpty) {
        isLoadingMedias.value = false;
        return;
      }

      // 3. Get media docs from 'Media' collection
      List<MediaItem> medias = [];
      for (var workout in postSessionWorkout) {
        final mediaId = workout['mediaId'];
        if (mediaId != null) {
          final mediaDoc = await FirebaseFirestore.instance.collection('Media').doc(mediaId.toString()).get();
          if (mediaDoc.exists) {
            final data = Map<String, dynamic>.from(mediaDoc.data()!);
            data['fromSession'] = sessionTitle;
            data['fromSessionId'] = visitId;
            medias.add(MediaItem.fromFirestore(data, mediaDoc.id));
          }
        }
      }

      postSessionMedias.assignAll(medias);
    } catch (e) {
      print('Error fetching post-session workouts: $e');
    } finally {
      isLoadingMedias.value = false;
    }
  }
  void changeTab(String tab) => selectedTab.value = tab;





  void playMedia(MediaItem item) {
    if (Get.isDialogOpen == true) {
      print('HomeController: Dialog already open, ignoring play request for ${item.title}');
      return;
    }
    print('HomeController: Playing media ${item.title}');
    
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: EmbeddedMediaPlayer(
          key: ValueKey(item.url),
          media: item,
          onProgressUpdate: (percentage) {
            // Update progress in local state
            final index = postSessionMedias.indexWhere((m) => m.id == item.id);
            if (index != -1) {
              postSessionMedias[index] = postSessionMedias[index].copyWith(progress: percentage);
              postSessionMedias.refresh();
            }
          },
          onClose: () => Get.back(),
        ),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black54,
    );
  }


}