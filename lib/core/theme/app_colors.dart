// core/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Light theme base
  static const Color bgLight = Color(0xFFF9FAFB);
  static const Color panelLight = Colors.white;
  static const Color cardLight = Colors.white;
  static const Color mutedLight = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF111827);

  // Accent (primary blue)
  static const Color accent = Color(0xFF0EA5E9);
  static const Color accent2 = Color(0xFF0284C7);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color danger = Color(0xFFEF4444);

  // Dark theme base
  static const Color bgDark = Color(0xFF111827);
  static const Color panelDark = Color(0xFF1F2937);
  static const Color cardDark = Color(0xFF374151);
  static const Color mutedDark = Color(0xFF9CA3AF);
  static const Color textDark = Color(0xFFF3F4F6);

  // Shared / derived
  static Color get glassLight => Colors.black.withOpacity(0.05);
  static Color get glassDark => Colors.white.withOpacity(0.05);

  static Color get shadowLight => Colors.black.withOpacity(0.08);
  static Color get shadowDark => Colors.black.withOpacity(0.5);
}