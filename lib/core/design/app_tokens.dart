import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Font families bundled in assets/fonts. Telugu glyphs fall back to
/// Noto Sans Telugu, so mixed English/Telugu text renders the same on every
/// device.
class AppFonts {
  AppFonts._();

  static const String sans = 'NotoSans';
  static const String telugu = 'NotoSansTelugu';
  static const List<String> fallback = [telugu];
}

class AppSpacing {
  AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;

  /// Standard horizontal page gutter.
  static const EdgeInsets page = EdgeInsets.symmetric(horizontal: md);
}

class AppRadii {
  AppRadii._();

  static const double input = 14;
  static const double button = 14;
  static const double card = 18;
  static const double sheet = 24;
  static const double pill = 999;

  static const BorderRadius inputAll = BorderRadius.all(Radius.circular(input));
  static const BorderRadius buttonAll = BorderRadius.all(Radius.circular(button));
  static const BorderRadius cardAll = BorderRadius.all(Radius.circular(card));
}

class AppShadows {
  AppShadows._();

  /// The soft shadow used on cards, tinted with the logo blue.
  static const List<BoxShadow> card = [BoxShadow(color: Color(0x12344A84), blurRadius: 18, offset: Offset(0, 6))];

  static const List<BoxShadow> raised = [BoxShadow(color: Color(0x2B1F2E57), blurRadius: 32, offset: Offset(0, 14))];

  /// Glow under primary buttons and hero cards.
  static const List<BoxShadow> brand = [BoxShadow(color: Color(0x40344A84), blurRadius: 18, offset: Offset(0, 8))];
}

/// Common decorations so cards look the same everywhere.
class AppDecorations {
  AppDecorations._();

  static BoxDecoration card({Color color = AppColors.surface, bool shadow = true}) => BoxDecoration(
    color: color,
    borderRadius: AppRadii.cardAll,
    border: Border.all(color: AppColors.border),
    boxShadow: shadow ? AppShadows.card : null,
  );

  static const BoxDecoration brandHeader = BoxDecoration(
    gradient: AppColors.brandGradient,
    borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
  );

  static const BoxDecoration heroCard = BoxDecoration(
    gradient: AppColors.brandGradient,
    borderRadius: AppRadii.cardAll,
    boxShadow: AppShadows.brand,
  );
}

/// Touch target and motion constants.
class AppSizes {
  AppSizes._();

  static const double minTouch = 48;
  static const double buttonHeight = 54;
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
}
