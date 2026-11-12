import 'dart:async';

import 'package:geolocator/geolocator.dart';

/// Gets a position without ever making the app wait long.
///
/// A fresh high-accuracy GPS fix can take many seconds indoors, or never arrive,
/// and screens were waiting for it. This uses a recent known position when there
/// is one, otherwise asks the GPS for at most [limit], and then falls back to
/// whatever position is known. Returns null only if there is none at all.
class QuickLocation {
  QuickLocation._();

  static const Duration recent = Duration(minutes: 2);

  static Future<Position?> get({
    Duration limit = const Duration(seconds: 4),
    LocationAccuracy accuracy = LocationAccuracy.medium,
    bool allowRecent = true,
    Future<Position?> Function()? lastKnown,
    Future<Position> Function()? fresh,
    DateTime Function()? now,
  }) async {
    Position? known;
    try {
      known = await (lastKnown ?? Geolocator.getLastKnownPosition)();
    } catch (_) {}

    final current = (now ?? DateTime.now)();
    if (allowRecent && known != null && current.difference(known.timestamp).abs() < recent) {
      return known;
    }

    try {
      final fetch = fresh ??
          () => Geolocator.getCurrentPosition(
                locationSettings: LocationSettings(accuracy: accuracy, timeLimit: limit),
              );
      return await fetch().timeout(limit);
    } catch (_) {
      return known;
    }
  }
}
