// lib/data/dummy_progress.dart
class DummyProgress {
  static final List<Map<String, dynamic>> _progressEntries = [
    {
      'date': '2025-01-10',
      'entries': [
        {'title': 'Morning Workout', 'progress': 85, 'notes': 'Chest & Back - felt strong'},
        {'title': 'Reading Goal', 'progress': 60, 'notes': 'Finished 2 chapters of Atomic Habits'},
      ]
    },
    {
      'date': '2025-01-15',
      'entries': [
        {'title': 'Coding Practice', 'progress': 90, 'notes': 'Solved 5 LeetCode medium problems'},
      ]
    },
    // ... other entries
  ];

  static List<Map<String, dynamic>> get progressEntries => _progressEntries;

  static List<Map<String, dynamic>> getProgressForDate(String dateStr) {
    final found = _progressEntries.firstWhere(
          (item) => item['date'] == dateStr,
      orElse: () => <String, dynamic>{'date': dateStr, 'entries': <Map<String, dynamic>>[]},
    );

    // If this is a new date → add it to the list
    if (!_progressEntries.any((item) => item['date'] == dateStr)) {
      _progressEntries.add(found);
    }

    return (found['entries'] as List<dynamic>).cast<Map<String, dynamic>>().toList();
  }

  // NEW: Add new progress entry
  static void addProgressEntry(String dateStr, {
    required String title,
    required int progress,
    String notes = '',
  }) {
    final found = _progressEntries.firstWhere(
          (item) => item['date'] == dateStr,
      orElse: () => <String, dynamic>{'date': dateStr, 'entries': <Map<String, dynamic>>[]},
    );

    if (!_progressEntries.any((item) => item['date'] == dateStr)) {
      _progressEntries.add(found);
    }

    (found['entries'] as List<dynamic>).add({
      'title': title,
      'progress': progress,
      'notes': notes,
    });
  }
}
/*
// lib/data/dummy_progress.dart

class DummyProgress {
  static final List<Map<String, dynamic>> progressEntries = [
    {
      'date': '2025-01-10',
      'entries': [
        {'title': 'Morning Workout', 'progress': 85, 'notes': 'Chest & Back - felt strong'},
        {'title': 'Reading Goal', 'progress': 60, 'notes': 'Finished 2 chapters of Atomic Habits'},
      ]
    },
    {
      'date': '2025-01-15',
      'entries': [
        {'title': 'Coding Practice', 'progress': 90, 'notes': 'Solved 5 LeetCode medium problems'},
      ]
    },
    {
      'date': '2025-01-18',
      'entries': [
        {'title': 'Meditation', 'progress': 100, 'notes': '20 min mindfulness session'},
        {'title': 'Water Intake', 'progress': 75, 'notes': '3.5L out of 4L goal'},
      ]
    },
    {
      'date': '2025-01-20',
      'entries': [
        {'title': 'Study Session', 'progress': 70, 'notes': 'Revised Flutter state management'},
      ]
    },
  ];

  static List<Map<String, dynamic>> getProgressForDate(String dateStr) {
    try {
      final item = progressEntries.firstWhere(
            (e) => e['date'] == dateStr,
        orElse: () => {'entries': <Map<String, dynamic>>[]},
      );

      final entries = item['entries'];
      if (entries is List) {
        return entries.cast<Map<String, dynamic>>().toList();
      }
      return [];
    } catch (e) {
      return [];
    }}}*/
