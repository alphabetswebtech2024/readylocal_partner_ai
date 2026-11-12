import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import '../design/app_colors.dart';
import '../design/app_tokens.dart';

/// App-wide Material 3 theme built from the ReadyLocal brand tokens
/// (primary #344A84, accent #C93438, the logo's colours) and the bundled Noto Sans fonts.
///
/// The app is light-only (main.dart uses [lightTheme] for both modes); the
/// other getters are kept for API compatibility and return the same theme.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => theme(lightScheme());
  static ThemeData get darkTheme => lightTheme;
  static ThemeData get lightMediumContrast => lightTheme;
  static ThemeData get lightHighContrast => lightTheme;
  static ThemeData get darkMediumContrast => lightTheme;
  static ThemeData get darkHighContrast => lightTheme;

  static ColorScheme lightScheme() => const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryTint,
        onPrimaryContainer: AppColors.primaryPressed,
        secondary: AppColors.accent,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.accentTint,
        onSecondaryContainer: AppColors.accentPressed,
        tertiary: AppColors.success,
        onTertiary: Colors.white,
        tertiaryContainer: AppColors.successTint,
        onTertiaryContainer: AppColors.success,
        error: AppColors.accent,
        onError: Colors.white,
        errorContainer: AppColors.accentTint,
        onErrorContainer: AppColors.accentPressed,
        surface: AppColors.surface,
        onSurface: AppColors.text,
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.borderStrong,
        outlineVariant: AppColors.border,
        shadow: Color(0xFF0F172A),
        scrim: Color(0xFF0F172A),
        inverseSurface: AppColors.ink,
        onInverseSurface: Colors.white,
        inversePrimary: AppColors.primaryTint,
        surfaceTint: Colors.transparent,
        surfaceContainerLowest: Colors.white,
        surfaceContainerLow: AppColors.surfaceMuted,
        surfaceContainer: AppColors.background,
        surfaceContainerHigh: Color(0xFFEFF3F8),
        surfaceContainerHighest: Color(0xFFE9EEF5),
      );

  static ColorScheme darkScheme() => lightScheme();
  static ColorScheme lightMediumContrastScheme() => lightScheme();
  static ColorScheme lightHighContrastScheme() => lightScheme();
  static ColorScheme darkMediumContrastScheme() => lightScheme();
  static ColorScheme darkHighContrastScheme() => lightScheme();

  static ThemeData theme(ColorScheme colorScheme) {
    final text = _textTheme(colorScheme);
    final buttonText = const TextStyle(
      fontFamily: AppFonts.sans,
      fontFamilyFallback: AppFonts.fallback,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );
    final inputBorder = const OutlineInputBorder(
      borderRadius: AppRadii.inputAll,
      borderSide: BorderSide(color: AppColors.border, width: 1.2),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      fontFamily: AppFonts.sans,
      fontFamilyFallback: AppFonts.fallback,
      textTheme: text,
      primaryTextTheme: text.apply(bodyColor: Colors.white, displayColor: Colors.white),
      primaryColor: colorScheme.primary,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.surface,
      splashFactory: InkRipple.splashFactory, // cheap on low-end phones; no shader compile on first tap
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: AppColors.border,
        centerTitle: false,
        titleSpacing: AppSpacing.md,
        titleTextStyle: text.titleLarge?.copyWith(color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white, size: 22),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.border,
          disabledForegroundColor: AppColors.textDisabled,
          elevation: 3,
          shadowColor: const Color(0x66344A84),
          minimumSize: const Size(64, AppSizes.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.buttonAll),
          textStyle: buttonText,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, AppSizes.buttonHeight),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.buttonAll),
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          minimumSize: const Size(64, AppSizes.minTouch),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12),
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.buttonAll),
          textStyle: buttonText.copyWith(fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          minimumSize: const Size(AppSizes.minTouch, 40),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.inputAll),
          textStyle: buttonText.copyWith(fontSize: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: text.bodyLarge?.copyWith(color: AppColors.textDisabled),
        labelStyle: text.bodyMedium?.copyWith(color: AppColors.textSecondary),
        floatingLabelStyle: text.bodyMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w600),
        errorStyle: text.bodySmall?.copyWith(color: AppColors.accent),
        prefixIconColor: AppColors.textMuted,
        suffixIconColor: AppColors.textMuted,
        border: inputBorder,
        enabledBorder: inputBorder,
        disabledBorder: inputBorder.copyWith(borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: inputBorder.copyWith(borderSide: BorderSide(color: colorScheme.primary, width: 1.6)),
        errorBorder: inputBorder.copyWith(borderSide: const BorderSide(color: AppColors.accent, width: 1.2)),
        focusedErrorBorder: inputBorder.copyWith(borderSide: const BorderSide(color: AppColors.accent, width: 1.6)),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.cardAll,
          side: BorderSide(color: AppColors.border),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primaryTint,
        side: const BorderSide(color: AppColors.border),
        labelStyle: text.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: const StadiumBorder(),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: AppColors.primaryTint,
        circularTrackColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1, space: AppSpacing.md),
      listTileTheme: ListTileThemeData(
        iconColor: colorScheme.primary,
        titleTextStyle: text.titleSmall,
        subtitleTextStyle: text.bodySmall?.copyWith(color: AppColors.textMuted),
        minVerticalPadding: 12,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.inputAll),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: AppColors.textMuted,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: colorScheme.primary,
        labelStyle: text.titleSmall,
        unselectedLabelStyle: text.titleSmall?.copyWith(fontWeight: FontWeight.w500),
        dividerColor: Colors.transparent,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? AppColors.success : AppColors.borderStrong,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        side: const BorderSide(color: AppColors.borderStrong, width: 1.5),
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? colorScheme.primary : null,
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? colorScheme.primary : AppColors.textDisabled,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AppRadii.sheet))),
        titleTextStyle: text.titleLarge?.copyWith(color: AppColors.ink),
        contentTextStyle: text.bodyMedium?.copyWith(color: AppColors.textSecondary),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.sheet))),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: text.bodyMedium?.copyWith(color: Colors.white),
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.inputAll),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(textStyle: text.bodyLarge),
      iconTheme: const IconThemeData(color: AppColors.textSecondary),
    );
  }

  static TextTheme _textTheme(ColorScheme scheme) {
    TextStyle style(double size, FontWeight weight, double height, {double spacing = 0, Color? color}) => TextStyle(
          fontFamily: AppFonts.sans,
          fontFamilyFallback: AppFonts.fallback,
          fontSize: size,
          fontWeight: weight,
          height: height,
          letterSpacing: spacing,
          color: color ?? AppColors.text,
        );

    return TextTheme(
      displayLarge: style(48, FontWeight.w700, 1.1, spacing: -0.5, color: AppColors.ink),
      displayMedium: style(40, FontWeight.w700, 1.15, spacing: -0.4, color: AppColors.ink),
      displaySmall: style(32, FontWeight.w700, 1.2, spacing: -0.3, color: AppColors.ink),
      headlineLarge: style(28, FontWeight.w700, 1.25, spacing: -0.2, color: AppColors.ink),
      headlineMedium: style(24, FontWeight.w700, 1.3, spacing: -0.1, color: AppColors.ink),
      headlineSmall: style(22, FontWeight.w700, 1.3, color: AppColors.ink),
      titleLarge: style(19, FontWeight.w700, 1.3, color: AppColors.ink),
      titleMedium: style(16, FontWeight.w700, 1.4, color: AppColors.ink),
      titleSmall: style(14, FontWeight.w600, 1.4, color: AppColors.ink),
      bodyLarge: style(16, FontWeight.w400, 1.5),
      bodyMedium: style(14, FontWeight.w400, 1.5),
      bodySmall: style(12, FontWeight.w400, 1.45, color: AppColors.textMuted),
      labelLarge: style(14, FontWeight.w600, 1.3),
      labelMedium: style(12, FontWeight.w600, 1.3),
      labelSmall: style(11, FontWeight.w600, 1.3, spacing: 0.2),
    );
  }
}

/// Status colours on the colour scheme, kept for existing callers.
extension CustomColors on ColorScheme {
  Color get success => AppColors.success;
  Color get warning => AppColors.warning;
  Color get info => AppColors.primary;
}
