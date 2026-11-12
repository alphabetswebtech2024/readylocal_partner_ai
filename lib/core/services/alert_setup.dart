import 'dart:io';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One thing on the phone that decides whether job alerts reach a closed app.
enum AlertStep { notifications, jobChannel, battery, autostart, popup }

/// What the phone reports. Autostart and pop-up have no readable state on any
/// phone, so the partner confirms them once and that is remembered.
class AlertSetupStatus {
  const AlertSetupStatus({
    required this.notifications,
    required this.jobChannel,
    required this.batteryUnrestricted,
    required this.backgroundRestricted,
    required this.hasAutostart,
    required this.isXiaomi,
    required this.confirmed,
  });

  /// Used where the phone can't be asked (iOS, tests, errors): nothing to fix.
  static const AlertSetupStatus allClear = AlertSetupStatus(
    notifications: true,
    jobChannel: true,
    batteryUnrestricted: true,
    backgroundRestricted: false,
    hasAutostart: false,
    isXiaomi: false,
    confirmed: {},
  );

  final bool notifications;
  final bool jobChannel;
  final bool batteryUnrestricted;
  final bool backgroundRestricted;
  final bool hasAutostart;
  final bool isXiaomi;
  final Set<AlertStep> confirmed;

  /// The steps that apply to this phone, in the order the partner does them.
  List<AlertStep> get steps => [
        AlertStep.notifications,
        if (notifications) AlertStep.jobChannel,
        AlertStep.battery,
        if (hasAutostart) AlertStep.autostart,
        if (isXiaomi) AlertStep.popup,
      ];

  bool isDone(AlertStep step) => switch (step) {
        AlertStep.notifications => notifications,
        AlertStep.jobChannel => jobChannel,
        AlertStep.battery => batteryUnrestricted && !backgroundRestricted,
        AlertStep.autostart || AlertStep.popup => confirmed.contains(step),
      };

  bool get allDone => steps.every(isDone);
  int get doneCount => steps.where(isDone).length;
}

/// Reads alert-related phone settings and opens the right settings page.
class AlertSetup {
  AlertSetup._();

  static const MethodChannel _channel = MethodChannel('com.readylocal.partner/alert_setup');
  static const String _confirmedKey = 'alertSetupConfirmed';
  static const String _promptedKey = 'alertSetupPrompted';

  /// Overridable for tests.
  static Future<AlertSetupStatus> Function()? debugStatus;

  static Future<AlertSetupStatus> status() async {
    if (debugStatus != null) return debugStatus!();
    if (!Platform.isAndroid) return AlertSetupStatus.allClear;
    try {
      final raw = Map<String, dynamic>.from(await _channel.invokeMethod<Map>('status') ?? const {});
      bool flag(String key, bool fallback) => raw[key] is bool ? raw[key] as bool : fallback;
      return AlertSetupStatus(
        notifications: flag('notifications', true),
        jobChannel: flag('jobChannel', true),
        batteryUnrestricted: flag('batteryUnrestricted', true),
        backgroundRestricted: flag('backgroundRestricted', false),
        hasAutostart: flag('hasAutostart', false),
        isXiaomi: flag('isXiaomi', false),
        confirmed: await _confirmed(),
      );
    } catch (_) {
      return AlertSetupStatus.allClear;
    }
  }

  static Future<bool> open(AlertStep step) async {
    try {
      return await _channel.invokeMethod<bool>('open', {'page': step.name}) ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<Set<AlertStep>> _confirmed() async {
    final prefs = await SharedPreferences.getInstance();
    final names = prefs.getStringList(_confirmedKey) ?? const [];
    return {for (final s in AlertStep.values) if (names.contains(s.name)) s};
  }

  static Future<void> setConfirmed(AlertStep step, bool done) async {
    final prefs = await SharedPreferences.getInstance();
    final names = {...prefs.getStringList(_confirmedKey) ?? const <String>[]};
    done ? names.add(step.name) : names.remove(step.name);
    await prefs.setStringList(_confirmedKey, names.toList());
  }

  /// True the first time only, so the guide opens by itself once per install.
  static Future<bool> takeFirstPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_promptedKey) ?? false) return false;
    await prefs.setBool(_promptedKey, true);
    return true;
  }
}
