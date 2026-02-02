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
  var currentJourney = 'None'.obs;
  var journeyProgress = 0.0.obs;
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
    await fetchCompletedSessions();
  }

  Future<void> fetchCompletedSessions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final historyQuery = await FirebaseFirestore.instance
          .collection('history')
          .where('patientId', isEqualTo: user.uid)
          .orderBy('date', descending: true)
          .get();

      if (historyQuery.docs.isEmpty) {
        completedSessions.clear();
        return;
      }

      // 1. Get Journey context from Patient profile as fallback
      final patientDoc = await FirebaseFirestore.instance.collection('Patients').doc(user.uid).get();
      final patientData = patientDoc.data() ?? {};
      final String? profileJourneyId = patientData['journeyId'];
      final String? profileJourneyName = patientData['journeyName'];

      // 2. Look at the latest history record
      final latestHistoryDoc = historyQuery.docs.first;
      final latestHistoryData = latestHistoryDoc.data();
      final String latestSessionId = latestHistoryData['sessionId'] ?? '';
      
      // Determine the effective Journey ID/Name to filter by
      String? effectiveJourneyId = latestHistoryData['journeyId'] ?? latestHistoryData['journeyName'] ?? profileJourneyId ?? profileJourneyName;

      List<Map<String, dynamic>> sessions = [];

      if (effectiveJourneyId == null || effectiveJourneyId.isEmpty) {
        // Condition A: Latest record is a single non-journey visit
        // Show ALL history records for this specific sessionId to catch duplicates
        for (var doc in historyQuery.docs) {
          final data = doc.data();
          if (data['sessionId'] == latestSessionId) {
            sessions.add({
              'id': doc.id,
              'title': data['sessionName'] ?? 'Untitled Session',
              'date': _formatTimestamp(data['date']),
              'sessionId': latestSessionId,
            });
          }
        }
      } else {
        // Condition B: Latest record or patient profile belongs to a journey
        // We first try to treat effectiveJourneyId as a Doc ID to get the VisitList
        List<dynamic> visitList = [];
        final journeyDoc = await FirebaseFirestore.instance.collection('Journeys').doc(effectiveJourneyId).get();
        if (journeyDoc.exists) {
          final data = journeyDoc.data() as Map<String, dynamic>;
          visitList = data['VisitList'] ?? [];
        } else {
          // If not found by ID, try searching by name
          final journeySearch = await FirebaseFirestore.instance
              .collection('Journeys')
              .where('journeyName', isEqualTo: effectiveJourneyId)
              .limit(1)
              .get();
          if (journeySearch.docs.isNotEmpty) {
            final data = journeySearch.docs.first.data() as Map<String, dynamic>;
            visitList = data['VisitList'] ?? [];
          }
        }
          
        // Filter ALL history records that match this journey context
        for (var doc in historyQuery.docs) {
          final data = doc.data();
          final hJid = data['journeyId'];
          final hJname = data['journeyName'];
          final sId = data['sessionId'];
          
          bool belongsToJourney = (hJid == effectiveJourneyId) || 
                                 (hJname == effectiveJourneyId) ||
                                 (sId != null && visitList.contains(sId));
                                   
          if (belongsToJourney) {
            sessions.add({
              'id': doc.id,
              'title': data['sessionName'] ?? 'Untitled Session',
              'date': _formatTimestamp(data['date']),
              'sessionId': sId,
            });
          }
        }
      }

      completedSessions.assignAll(sessions);
    } catch (e) {
      print('HomeController: Error in fetchCompletedSessions: $e');
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    DateTime dt;
    if (timestamp is Timestamp) {
      dt = timestamp.toDate();
    } else if (timestamp is String) {
      dt = DateTime.tryParse(timestamp) ?? DateTime.now();
    } else {
      dt = DateTime.now();
    }
    final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return "${dt.day} ${months[dt.month - 1]}";
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
      final String? journeyName = patientData['journeyName'];
      final String? visitIdInProgress = patientData['visitIdInProgress'];

      // Handle Non-Journey Case
      if ((journeyId == null || journeyId.isEmpty) && (journeyName == null || journeyName.isEmpty)) {
        print('HomeController: User not on a journey, defaulting to Past tab');
        currentJourney.value = 'None';
        journeyProgress.value = 1.0; 
        selectedTab.value = 'past';
        upcomingMedias.clear();
        postSessionMedias.clear(); // Next tab should be empty if not on journey
        
        final List<MediaItem> fullHistory = await _fetchCompleteMediaHistory(user.uid);
        pastMedias.assignAll(fullHistory);
        allMedias.assignAll(fullHistory);
        return;
      }

      // 2. Fetch Journey Doc (Try by ID first, then by Name)
      DocumentSnapshot journeyDoc;
      if (journeyId != null && journeyId.isNotEmpty) {
        journeyDoc = await FirebaseFirestore.instance.collection('Journeys').doc(journeyId).get();
      } else if (journeyName != null && journeyName.isNotEmpty) {
        final search = await FirebaseFirestore.instance
            .collection('Journeys')
            .where('journeyName', isEqualTo: journeyName)
            .limit(1)
            .get();
        if (search.docs.isNotEmpty) {
          journeyDoc = search.docs.first;
        } else {
          // Final fallback: try to use name as Doc ID
          journeyDoc = await FirebaseFirestore.instance.collection('Journeys').doc(journeyName).get();
        }
      } else {
        // Should not happen due to check above
        return;
      }

      if (!journeyDoc.exists) {
        currentJourney.value = 'None';
        journeyProgress.value = 1.0;
        return;
      }

      final journeyData = journeyDoc.data() as Map<String, dynamic>;
      currentJourney.value = journeyData['journeyName'] ?? 'Unknown Journey';
      final List<dynamic>? visitList = journeyData['VisitList'];
      if (visitList == null || visitList.isEmpty) {
        journeyProgress.value = 1.0;
        return;
      }

      int currentIndex = -1;
      if (visitIdInProgress != null && visitIdInProgress.isNotEmpty) {
        currentIndex = visitList.indexOf(visitIdInProgress);
      }

      // Calculate progress: visits before the current one are done.
      if (currentIndex == -1) {
        // Not started? or completed? 
        // If visitIdInProgress is not in the list, maybe it's done or not started.
        journeyProgress.value = 0.0;
      } else {
        journeyProgress.value = currentIndex / visitList.length;
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

  Future<List<MediaItem>> _fetchCompleteMediaHistory(String patientId) async {
    List<MediaItem> allMedias = [];
    try {
      final historyQuery = await FirebaseFirestore.instance
          .collection('history')
          .where('patientId', isEqualTo: patientId)
          .orderBy('date', descending: true)
          .get();

      Set<String> processedSessionIds = {};

      for (var doc in historyQuery.docs) {
        final data = doc.data();
        final sessionId = data['sessionId'];
        if (sessionId != null && sessionId is String && sessionId.isNotEmpty) {
          if (processedSessionIds.contains(sessionId)) continue;
          processedSessionIds.add(sessionId);

          final visitMedia = await _fetchMediaForVisit(sessionId);
          for (var item in visitMedia) {
            if (!allMedias.any((m) => m.id == item.id)) {
              allMedias.add(item);
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching complete media history: $e');
    }
    return allMedias;
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