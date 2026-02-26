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

  /// Fetches all activity dates for the current user (Media + History).
  static Future<Set<String>> fetchActivityDates() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {};

    try {
      // 1. Fetch from activity_log (Media plays)
      final mediaQuery = await _firestore
          .collection('activity_log')
          .where('userId', isEqualTo: user.uid)
          .get();
      final mediaDates = mediaQuery.docs.map((doc) => doc.data()['date'] as String);

      // 2. Fetch from history (Clinical sessions)
      final historyQuery = await _firestore
          .collection('history')
          .where('patientId', isEqualTo: user.uid)
          .get();
      final historyDates = historyQuery.docs.map((doc) {
        final data = doc.data();
        final timestamp = data['date'];
        if (timestamp is Timestamp) {
          return DateFormat('yyyy-MM-dd').format(timestamp.toDate());
        } else if (timestamp is String) {
          return timestamp.substring(0, 10); // Assume yyyy-MM-dd...
        }
        return '';
      }).where((d) => d.isNotEmpty);

      return {...mediaDates, ...historyDates};
    } catch (e) {
      print('ActivityLogger: Error fetching activity dates: $e');
      return {};
    }
  }

  /// Fetches detailed activity records per date.
  static Future<Map<String, List<Map<String, dynamic>>>> fetchDetailedActivity() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {};

    Map<String, List<Map<String, dynamic>>> results = {};

    try {
      // 1. Fetch Media Activity
      final mediaQuery = await _firestore
          .collection('activity_log')
          .where('userId', isEqualTo: user.uid)
          .get();

      for (var doc in mediaQuery.docs) {
        final data = doc.data();
        final date = data['date'] as String;
        final mediaId = data['mediaId'] as String;
        
        // We might want to fetch the media title here, but for now we'll label it "Media Session"
        results.putIfAbsent(date, () => []).add({
          'type': 'media',
          'title': 'Watched Media Workout',
          'id': mediaId,
        });
      }

      // 2. Fetch Clinical History
      final historyQuery = await _firestore
          .collection('history')
          .where('patientId', isEqualTo: user.uid)
          .get();

      for (var doc in historyQuery.docs) {
        final data = doc.data();
        final timestamp = data['date'];
        String date = '';
        if (timestamp is Timestamp) {
          date = DateFormat('yyyy-MM-dd').format(timestamp.toDate());
        } else if (timestamp is String) {
          date = timestamp.substring(0, 10);
        }

        if (date.isNotEmpty) {
          results.putIfAbsent(date, () => []).add({
            'type': 'clinical',
            'title': data['sessionName'] ?? 'Clinical Session',
            'id': data['sessionId']?.toString() ?? '',
          });
        }
      }
    } catch (e) {
      print('ActivityLogger: Error fetching detailed activity: $e');
    }

    return results;
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
