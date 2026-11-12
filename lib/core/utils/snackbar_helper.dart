import 'package:flutter/material.dart';
import '../session/app_session.dart';
import 'package:gotask_partner/core/design/app_colors.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';

/// Centralized SnackBar helper to replace Get.snackbar across all screens.
class AppSnackBar {
  AppSnackBar._();

  static void show(
    String title,
    String message, {
    Color? backgroundColor,
    Color textColor = Colors.white,
    Duration duration = const Duration(seconds: 3),
    IconData? icon,
  }) {
    final context = AppSession.navigatorKey.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor, size: 20),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title.isNotEmpty)
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        fontSize: 14,
                      ),
                    ),
                  if (message.isNotEmpty)
                    Text(
                      message,
                      style: TextStyle(color: textColor, fontSize: 13, height: 1.4),
                    ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor ?? AppColors.ink,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        duration: duration,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static void error(String message, {String? title}) {
    show(title ?? L10n.current.snackError, message, backgroundColor: AppColors.accent, icon: Icons.error_outline_rounded);
  }

  static void success(String message, {String? title}) {
    show(title ?? L10n.current.snackSuccess, message, backgroundColor: AppColors.success, icon: Icons.check_circle_outline_rounded);
  }

  static void info(String message, {String? title}) {
    show(title ?? L10n.current.snackNotice, message, backgroundColor: AppColors.ink, icon: Icons.info_outline_rounded);
  }

  static void showError(dynamic contextOrMessage, [String? message]) {
    if (contextOrMessage is BuildContext && message != null) {
      error(message);
    } else if (contextOrMessage is String) {
      error(contextOrMessage);
    }
  }

  static void showSuccess(dynamic contextOrMessage, [String? message]) {
    if (contextOrMessage is BuildContext && message != null) {
      success(message);
    } else if (contextOrMessage is String) {
      success(contextOrMessage);
    }
  }
}
