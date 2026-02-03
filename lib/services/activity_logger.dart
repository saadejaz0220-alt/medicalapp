import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

/// Service to log user activity for streak tracking.
class ActivityLogger {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Logs a media play event for the current user.
  /// Only logs once per day per user to count as a single activity day.
  static Future<void> logMediaPlay(String mediaId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      // Check if an entry already exists for today
      final existing = await _firestore
          .collection('activity_log')
          .where('userId', isEqualTo: user.uid)
          .where('date', isEqualTo: today)
          .limit(1)
          .get();

      if (existing.docs.isEmpty) {
        // No entry for today, create one
        await _firestore.collection('activity_log').add({
          'userId': user.uid,
          'date': today,
          'mediaId': mediaId,
          'timestamp': FieldValue.serverTimestamp(),
        });
        print('ActivityLogger: Logged activity for $today');
      } else {
        print('ActivityLogger: Activity already logged for $today');
      }
    } catch (e) {
      print('ActivityLogger: Error logging activity: $e');
    }
  }

  /// Fetches all activity dates for the current user.
  static Future<Set<String>> fetchActivityDates() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {};

    try {
      final query = await _firestore
          .collection('activity_log')
          .where('userId', isEqualTo: user.uid)
          .get();

      return query.docs.map((doc) => doc.data()['date'] as String).toSet();
    } catch (e) {
      print('ActivityLogger: Error fetching activity dates: $e');
      return {};
    }
  }

  /// Calculates the current streak (consecutive days ending today or yesterday).
  static int calculateStreak(Set<String> activityDates) {
    if (activityDates.isEmpty) return 0;

    final sortedDates = activityDates.toList()..sort((a, b) => b.compareTo(a)); // Descending
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final yesterday = DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 1)));

    // Streak must start from today or yesterday
    if (!sortedDates.contains(today) && !sortedDates.contains(yesterday)) {
      return 0;
    }

    int streak = 0;
    DateTime checkDate = sortedDates.contains(today) 
        ? DateTime.now() 
        : DateTime.now().subtract(const Duration(days: 1));

    while (true) {
      final checkStr = DateFormat('yyyy-MM-dd').format(checkDate);
      if (activityDates.contains(checkStr)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// Calculates the longest streak ever achieved from activity dates.
  static int calculateLongestStreak(Set<String> activityDates) {
    if (activityDates.isEmpty) return 0;

    final sortedDates = activityDates.toList()..sort(); // Ascending
    int maxStreak = 0;
    int currentStreak = 0;
    DateTime? prevDate;

    for (final dateStr in sortedDates) {
      final currentDate = DateFormat('yyyy-MM-dd').parse(dateStr);
      
      if (prevDate == null) {
        currentStreak = 1;
      } else {
        final difference = currentDate.difference(prevDate).inDays;
        if (difference == 1) {
          currentStreak++;
        } else if (difference > 1) {
          if (currentStreak > maxStreak) {
            maxStreak = currentStreak;
          }
          currentStreak = 1;
        }
      }
      prevDate = currentDate;
    }

    if (currentStreak > maxStreak) {
      maxStreak = currentStreak;
    }

    return maxStreak;
  }

  /// Calculates how many unique days the user was active this current month.
  static int calculateDaysActiveThisMonth(Set<String> activityDates) {
    if (activityDates.isEmpty) return 0;

    final now = DateTime.now();
    final currentMonthStr = DateFormat('yyyy-MM').format(now);
    
    return activityDates.where((date) => date.startsWith(currentMonthStr)).length;
  }
}
