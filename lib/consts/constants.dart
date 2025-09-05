import 'package:flutter/material.dart';

class Constants {
  // Brand / primary
  static const Color primary = Color(0xFF0A73B7);
  static const Color primaryLight = Color(0xFF4EA7E6);
  static const Color primaryDark = Color(0xFF005A9C);

  // Secondary (positive/attendance)
  static const Color secondary = Color(0xFF2EA36A);
  static const Color secondaryLight = Color(0xFF66D29A);
  static const Color secondaryDark = Color(0xFF1B7A46);

  // Neutrals
  static const Color background = Color(0xFFF6F9FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color muted = Color(0xFF6B7280);
  static const Color border = Color(0xFFE6EEF6);

  // Semantic
  static const Color success = Color(0xFF2E7D32);
  static const Color info = Color(0xFF0288D1);
  static const Color warning = Color(0xFFF57C00);
  static const Color error = Color(0xFFB00020);

  // On-colors (text/icons on respective backgrounds)
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF111827);
  static const Color onBackground = Color(0xFF111827);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}