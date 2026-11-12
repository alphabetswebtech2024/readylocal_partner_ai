// Screens must not wait on a slow or missing GPS fix, and Home must not load twice.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gotask_partner/core/services/quick_location.dart';
import 'package:gotask_partner/core/widgets/common_loading_overlay.dart';

Position _at(DateTime t) => Position(
      latitude: 17.4,
      longitude: 78.3,
      timestamp: t,
      accuracy: 5,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );

void main() {
  final now = DateTime(2026, 11, 5, 12);

  group('QuickLocation', () {
    test('a recent position is returned without asking the GPS', () async {
      var asked = false;
      final p = await QuickLocation.get(
        now: () => now,
        lastKnown: () async => _at(now.subtract(const Duration(seconds: 30))),
        fresh: () async {
          asked = true;
          return _at(now);
        },
      );
      expect(p, isNotNull);
      expect(asked, isFalse);
    });

    test('a GPS that never answers ends at the limit and uses the old position', () async {
      final old = _at(now.subtract(const Duration(hours: 3)));
      final sw = Stopwatch()..start();
      final p = await QuickLocation.get(
        limit: const Duration(milliseconds: 100),
        now: () => now,
        lastKnown: () async => old,
        fresh: () => Completer<Position>().future,
      );
      expect(p, same(old));
      expect(sw.elapsed.inMilliseconds, lessThan(1000));
    });

    test('no position at all gives null, not an error', () async {
      final p = await QuickLocation.get(
        limit: const Duration(milliseconds: 50),
        now: () => now,
        lastKnown: () async => null,
        fresh: () => Future<Position>.error('no gps'),
      );
      expect(p, isNull);
    });
  });

  group('Loading overlay', () {
    Widget host(bool loading, VoidCallback onTap) => MaterialApp(
          home: CommonLoadingOverlay(
            isLoading: loading,
            child: Center(child: ElevatedButton(onPressed: onTap, child: const Text('Go'))),
          ),
        );

    testWidgets('no spinner on a quick load, spinner on a long one, no blur', (tester) async {
      await tester.pumpWidget(host(true, () {}));
      expect(find.byType(CircularProgressIndicator), findsNothing);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('taps are blocked from the first moment of loading', (tester) async {
      var taps = 0;
      await tester.pumpWidget(host(true, () => taps++));
      await tester.tap(find.text('Go'), warnIfMissed: false);
      expect(taps, 0);
      await tester.pumpWidget(host(false, () => taps++));
      await tester.tap(find.text('Go'));
      expect(taps, 1);
      await tester.pump(const Duration(milliseconds: 300));
    });
  });
}
