import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart' show openAppSettings;

import 'package:go_router/go_router.dart';

import '../../app/router/route_names.dart';
import '../localization/locale_provider.dart';
import '../services/alert_setup.dart';
import 'app_colors.dart';
import 'app_tokens.dart';

/// Shown on Home only when something on the phone can stop job alerts
/// (notifications off, battery limits, Autostart not confirmed). It never
/// blocks anything; "Fix" opens the step-by-step job alert setup. The setup
/// also opens by itself once, the first time it is needed.
class JobAlertsNotice extends StatefulWidget {
  const JobAlertsNotice({super.key, this.checkBlocked});

  /// Overridable for tests: true when job alerts can be missed.
  final Future<bool> Function()? checkBlocked;

  @override
  State<JobAlertsNotice> createState() => _JobAlertsNoticeState();
}

class _JobAlertsNoticeState extends State<JobAlertsNotice> with WidgetsBindingObserver {
  bool _blocked = false;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check(firstTime: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Re-check when the partner comes back from the phone's settings.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check();
  }

  static Future<bool> _notificationsDenied() async {
    if (Firebase.apps.isEmpty) return false;
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.denied;
  }

  Future<void> _check({bool firstTime = false}) async {
    try {
      bool blocked;
      if (widget.checkBlocked != null) {
        blocked = await widget.checkBlocked!();
        _permissionDenied = blocked;
      } else if (Platform.isAndroid) {
        final status = await AlertSetup.status();
        blocked = !status.allDone;
        _permissionDenied = !status.notifications;
      } else {
        blocked = await _notificationsDenied();
        _permissionDenied = blocked;
      }
      if (mounted && blocked != _blocked) setState(() => _blocked = blocked);
      if (firstTime && blocked && widget.checkBlocked == null && Platform.isAndroid) {
        if (await AlertSetup.takeFirstPrompt() && mounted) {
          await Future<void>.delayed(const Duration(milliseconds: 1200));
          if (mounted && (ModalRoute.of(context)?.isCurrent ?? false)) context.push(AppRoutes.alertSetup);
        }
      }
    } catch (_) {}
  }

  void _fix() {
    if (Platform.isAndroid) {
      context.push(AppRoutes.alertSetup);
    } else {
      openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_blocked) return const SizedBox.shrink();
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
      child: Material(
        color: AppColors.accentTint,
        borderRadius: AppRadii.inputAll,
        child: InkWell(
          borderRadius: AppRadii.inputAll,
          onTap: _fix,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: AppRadii.inputAll,
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                Icon(_permissionDenied ? Icons.notifications_off_outlined : Icons.notifications_paused_outlined,
                    color: AppColors.accent),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_permissionDenied ? l10n.alertsOffTitle : l10n.alertsSetupNeededTitle,
                          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink)),
                      Text(_permissionDenied ? l10n.alertsOffBody : l10n.alertsSetupNeededBody,
                          style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                TextButton(onPressed: _fix, child: Text(_permissionDenied ? l10n.alertsTurnOn : l10n.alertsFix)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Steps for keeping job alerts working when the app is closed. Phone makers'
/// battery savers can block pushes and only the partner can change that.
Future<void> showJobAlertSettings(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.sheet))),
    builder: (sheetContext) {
      final l10n = sheetContext.l10n;
      Widget step(IconData icon, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 21, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 14, color: AppColors.text))),
          ],
        ),
      );
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.alertsSettingsTitle, style: Theme.of(sheetContext).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(l10n.alertsSettingsIntro, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.xs),
              step(Icons.notifications_active_outlined, l10n.alertsStepNotifications),
              step(Icons.battery_charging_full_rounded, l10n.alertsStepBattery),
              step(Icons.rocket_launch_outlined, l10n.alertsStepAutostart),
              step(Icons.block_rounded, l10n.alertsStepForceStop),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(onPressed: openAppSettings, child: Text(l10n.alertsOpenSettings)),
            ],
          ),
        ),
      );
    },
  );
}
