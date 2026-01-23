class DummyLabels {
  static final Map<String, String> dateLabels = {
    '2025-01-10': 'Strong Day',
    '2025-01-15': 'Coding Win',
    '2025-01-18': 'Rest Day',
    '2025-01-20': 'Study Boost',
    // Add more as needed
  };

  static String? getLabelForDate(String dateStr) {
    return dateLabels[dateStr];
  }
}