import 'package:flutter/material.dart';

/// Vazhii Brand Color Palette
/// Designed according to brand guidelines:
/// - Primary: Red `#E3262E`
/// - Background: White `#FFFFFF`
/// - Text: Charcoal `#242424`
class AppColors {
  AppColors._();

  // Core Brand Colors
  static const Color primary = Color(0xFFE3262E);
  static const Color primaryDark = Color(0xFFB81B22);
  static const Color primaryLight = Color(0xFFFFF0F1);
  static const Color primaryMuted = Color(0xFFFFD9DC);

  // Backgrounds
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8F9FA);
  static const Color scaffoldBackground = Color(0xFFFAFAFA);

  // Text Colors
  static const Color textPrimary = Color(0xFF242424);
  static const Color textSecondary = Color(0xFF687076);
  static const Color textMuted = Color(0xFF9BA1A6);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Borders & Dividers
  static const Color border = Color(0xFFE8ECEF);
  static const Color borderSubtle = Color(0xFFF1F3F5);

  // Functional Status Colors
  static const Color success = Color(0xFF1B873F);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFE67E22);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color info = Color(0xFF206095);
  static const Color infoLight = Color(0xFFE1F0FA);

  // Card & Shadow
  static const Color cardShadow = Color(0x0F000000);
}

