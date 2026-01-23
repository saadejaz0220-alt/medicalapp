// presentation/screens/calendar/calendar_controller.dart
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../data/dummy_data/dummy_data.dart';
import '../../data/dummy_data/dummy_label.dart';
import '../../data/dummy_data/dummydata_progress.dart'; // or your data source

class CalendarController extends GetxController {
  var selectedTab = 'next'.obs;
  final RxInt currentMonth = DateTime.now().month.obs;
  final RxInt currentYear = DateTime.now().year.obs;

  final RxString streakText = 'Current Streak: 0 days'.obs;

  // In CalendarController
  String? getLabelForDate(String dateStr) {
    return DummyLabels.getLabelForDate(dateStr);
  }
  
  late final List<String> completedDates;

  @override
  void onInit() {
    super.onInit();
    // Extract completed dates once
    completedDates = DummyData.sessions
        .where((s) => s['status'] == 'completed')
        .map<String>((s) => s['date'] as String)
        .toList();

    updateStreak(); // initial
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

    updateStreak(); // optional: could recalculate real streak
  }

  String get monthYearDisplay {
    final date = DateTime(currentYear.value, currentMonth.value);
    return DateFormat('MMMM yyyy').format(date);
  }

  bool isCompleted(String dateStr) {
    return completedDates.contains(dateStr);
  }

  bool isToday(int day) {
    final now = DateTime.now();
    return now.year == currentYear.value &&
        now.month == currentMonth.value &&
        now.day == day;
  }

  void updateStreak() {
    // Simple mock – in real app you'd calculate from actual logs
    // Here we just use the value from dummy data / state
    streakText.value = 'Current Streak: 7 days';
  }
}
