import 'package:flutter/material.dart';

/// Brand and neutral colour tokens. Blue and red are the exact colours of the
/// ReadyLocal logo. Every screen takes colours from here or from the theme.
class AppColors {
  AppColors._();

  // Brand: logo blue
  static const Color primary = Color(0xFF344A84);
  static const Color primaryPressed = Color(0xFF2A3C6C);
  static const Color primaryDeep = Color(0xFF1F2E57);
  static const Color primaryLight = Color(0xFF4A63A6);
  static const Color primaryTint = Color(0xFFEDF0F8);
  static const Color primaryTintBorder = Color(0xFFD6DCEC);
  static const Color onPrimaryMuted = Color(0xFFCDD6EC);

  // Brand: logo red
  static const Color accent = Color(0xFFC93438);
  static const Color accentPressed = Color(0xFFA92A2E);
  static const Color accentTint = Color(0xFFFBECEC);

  // Status
  static const Color success = Color(0xFF15803D);
  static const Color successTint = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFB45309);
  static const Color warningTint = Color(0xFFFEF3C7);
  static const Color danger = accent;
  static const Color dangerTint = accentTint;

  // Neutrals
  static const Color ink = Color(0xFF141C33);
  static const Color text = Color(0xFF232C43);
  static const Color textSecondary = Color(0xFF4B556D);
  static const Color textMuted = Color(0xFF69738A);
  static const Color textDisabled = Color(0xFF98A1B5);
  static const Color border = Color(0xFFE5E9F2);
  static const Color borderStrong = Color(0xFFCDD4E3);
  static const Color divider = Color(0xFFEEF1F7);
  static const Color background = Color(0xFFF3F5FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF8F9FD);
  static const Color skeleton = Color(0xFFE8ECF5);

  /// Headers and hero cards.
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDeep, primary, primaryLight],
    stops: [0, 0.55, 1],
  );

  /// The logo's blue-to-red sweep, used only as a thin accent line.
  static const LinearGradient brandRibbon = LinearGradient(colors: [primary, accent]);
}
