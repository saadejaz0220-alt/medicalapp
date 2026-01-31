import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/session_model.dart';
import '../../../app/routes/app_routes.dart';
import '../../data/dummy_data/dummy_data.dart';

class SessionDetailController extends GetxController {
  final Rx<Session?> session = Rx<Session?>(null);
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    final id = Get.parameters['id'] != null ? int.tryParse(Get.parameters['id']!) : null;

    if (id == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar('Error', 'Invalid session ID');
        Get.back();
      });
      isLoading.value = false;
      return;
    }

    final found = DummyData.sessions.firstWhere(
          (s) => s['id'] == id,
      orElse: () => <String, dynamic>{},
    );

    if (found.isNotEmpty) {
      session.value = Session(
        id: found['id'],
        title: found['title'],
        date: found['date'],
        status: found['status'],
        progress: found['progress'],
        duration: found['duration'],
        type: found['type'],
        thumbnailUrl: "https://i.ytimg.com/vi/dQw4w9WgXcQ/maxresdefault.jpg", // fallback
      );
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar('Not Found', 'Session not found');
        Get.back();
      });
    }

    isLoading.value = false;
  }

  bool get isCompleted => session.value?.status == 'completed';
  bool get isNextOrUpcoming => session.value?.status == 'next' || session.value?.status == 'upcoming';

  String get actionButtonText => isCompleted ? 'Replay Session' : 'Start Session';

  Color get badgeColor {
    final s = session.value?.status;
    if (s == 'completed') return Get.theme.colorScheme.primary.withOpacity(0.9); // green
    if (s == 'next') return Get.theme.colorScheme.secondary; // blue
    return Colors.orange;
  }

  void playSession() {
    if (session.value == null) {
      Get.snackbar('Error', 'No session data');
      return;
    }

    Get.toNamed(
      AppRoutes.SESSION_PLAYER,
      arguments: session.value,
    );

    if (session.value!.progress < 10) {
      session.value!.progress = 10;
      session.refresh();
    }
  }
  /*void playSession() {
    // In real app → open full player (youtube_player_flutter / video_player / external browser)
    Get.snackbar(
      'Playing',
      '${session.value?.title} – ${session.value?.duration}m',
      duration: const Duration(seconds: 3),
    );

    // Optional: mark as started / update progress
    if (session.value != null && session.value!.progress < 100) {
      session.value!.progress = 50; // demo
      update(); // or use .refresh() if list
    }
  }*/

  void goBack() => Get.back();
}