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
  var upcomingMedias = <MediaItem>[].obs;
  var pastMedias = <MediaItem>[].obs;
  var allMedias = <MediaItem>[].obs;
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
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    await fetchPostSessionWorkouts();
    await fetchJourneyData();
  }

  Future<void> fetchJourneyData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // 1. Fetch Patient Doc
      final patientDoc = await FirebaseFirestore.instance.collection('Patients').doc(user.uid).get();
      if (!patientDoc.exists) return;

      final patientData = patientDoc.data()!;
      final String? journeyId = patientData['journeyId'];
      final String? visitIdInProgress = patientData['visitIdInProgress'];

      if (journeyId == null || journeyId.isEmpty) {
        print('HomeController: User not on a journey');
        return;
      }

      // 2. Fetch Journey Doc
      final journeyDoc = await FirebaseFirestore.instance.collection('Journeys').doc(journeyId).get();
      if (!journeyDoc.exists) return;

      final journeyData = journeyDoc.data()!;
      final List<dynamic>? visitList = journeyData['VisitList'];
      if (visitList == null || visitList.isEmpty) return;

      int currentIndex = -1;
      if (visitIdInProgress != null && visitIdInProgress.isNotEmpty) {
        currentIndex = visitList.indexOf(visitIdInProgress);
      }

      List<MediaItem> past = [];
      List<MediaItem> upcoming = [];
      List<MediaItem> all = [];

      // 3. Categorize Visits
      for (int i = 0; i < visitList.length; i++) {
        final vId = visitList[i].toString();
        final visitMedia = await _fetchMediaForVisit(vId);
        
        all.addAll(visitMedia);
        if (currentIndex != -1) {
          if (i < currentIndex) {
            past.addAll(visitMedia);
          } else if (i > currentIndex) {
            upcoming.addAll(visitMedia);
          }
        } else {
          // If no progress yet, all are upcoming? 
          // Actually, if visitIdInProgress is empty, maybe they haven't started.
          upcoming.addAll(visitMedia);
        }
      }

      pastMedias.assignAll(past);
      upcomingMedias.assignAll(upcoming);
      allMedias.assignAll(all);

    } catch (e) {
      print('Error fetching journey data: $e');
    }
  }

  Future<List<MediaItem>> _fetchMediaForVisit(String sessionId) async {
    List<MediaItem> visitMedias = [];
    try {
      final visitDoc = await FirebaseFirestore.instance.collection('Visits').doc(sessionId).get();
      if (!visitDoc.exists) return [];

      final visitData = visitDoc.data()!;
      final String sessionTitle = visitData['visitName'] ?? 'Untitled Session';
      final String visitId = visitData['visitId'] ?? sessionId;
      final List<dynamic>? postSessionWorkout = visitData['postSessionWorkout'];

      if (postSessionWorkout != null) {
        for (var workout in postSessionWorkout) {
          final mediaId = workout['mediaId'];
          if (mediaId != null) {
            final mediaDoc = await FirebaseFirestore.instance.collection('Media').doc(mediaId.toString()).get();
            if (mediaDoc.exists) {
              final data = Map<String, dynamic>.from(mediaDoc.data()!);
              data['fromSession'] = sessionTitle;
              data['fromSessionId'] = visitId;
              visitMedias.add(MediaItem.fromFirestore(data, mediaDoc.id));
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching media for visit $sessionId: $e');
    }
    return visitMedias;
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
            // Update progress in ALL relevant lists
            _updateProgressInList(postSessionMedias, item.id, percentage);
            _updateProgressInList(upcomingMedias, item.id, percentage);
            _updateProgressInList(pastMedias, item.id, percentage);
            _updateProgressInList(allMedias, item.id, percentage);
          },
          onClose: () => Get.back(),
        ),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black54,
    );
  }  void _updateProgressInList(RxList<MediaItem> list, String mediaId, double percentage) {
    final index = list.indexWhere((m) => m.id == mediaId);
    if (index != -1) {
      list[index] = list[index].copyWith(progress: percentage);
      list.refresh();
    }
  }
}