// presentation/screens/calendar/calendar_controller.dart
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../services/activity_logger.dart';

class CalendarController extends GetxController {
  var selectedTab = 'next'.obs;
  final RxInt currentMonth = DateTime.now().month.obs;
  final RxInt currentYear = DateTime.now().year.obs;

  final RxString streakText = 'Current Streak: 0 days'.obs;
  final RxSet<String> activityDates = <String>{}.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchActivityData();
  }

  Future<void> fetchActivityData() async {
    isLoading.value = true;
    try {
      final dates = await ActivityLogger.fetchActivityDates();
      activityDates.assignAll(dates);
      updateStreak();
    } catch (e) {
      print('CalendarController: Error fetching activity data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void changeMonth(int delta) {
    currentMonth.value += delta;

    while (currentMonth.value > 12) {
      currentMonth.value -= 12;
      currentYear.value++;
    }
    while (currentMonth.value < 1) {
      currentMonth.value += 12;
      currentYear.value--;
    }
  }

  String get monthYearDisplay {
    final date = DateTime(currentYear.value, currentMonth.value);
    return DateFormat('MMMM yyyy').format(date);
  }

  bool isCompleted(String dateStr) {
    return activityDates.contains(dateStr);
  }

  bool isToday(int day) {
    final now = DateTime.now();
    return now.year == currentYear.value &&
        now.month == currentMonth.value &&
        now.day == day;
  }

  void updateStreak() {
    final streak = ActivityLogger.calculateStreak(activityDates.toSet());
    if (streak == 0) {
      streakText.value = 'No streak yet — start today!';
    } else if (streak == 1) {
      streakText.value = 'Current Streak: 1 day 🔥';
    } else {
      streakText.value = 'Current Streak: $streak days 🔥';
    }
  }
}
