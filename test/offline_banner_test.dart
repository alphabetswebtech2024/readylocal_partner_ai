import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotask_partner/core/design/offline_banner.dart';

void main() {
  testWidgets('offline notice appears and disappears with connectivity', (tester) async {
    final changes = StreamController<List<ConnectivityResult>>();
    addTearDown(changes.close);
    await tester.pumpWidget(MaterialApp(
      home: OfflineBanner(
        changes: changes.stream,
        check: () async => [ConnectivityResult.wifi],
        child: const Scaffold(body: Text('screen')),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.wifi_off_rounded), findsNothing);

    changes.add([ConnectivityResult.none]);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
    expect(find.textContaining("You're offline"), findsOneWidget);
    expect(find.text('screen'), findsOneWidget, reason: 'the screen stays usable');

    changes.add([ConnectivityResult.mobile]);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.wifi_off_rounded), findsNothing);
  });
}
