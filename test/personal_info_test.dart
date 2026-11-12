// New partner registration: the Personal Information step (6 Nov behaviour).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gotask_partner/core/session/app_session.dart';
import 'package:gotask_partner/features/personal_information/presentation/screens/personal_information_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_screens/harness.dart';

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

String currentPath() =>
    GoRouter.of(AppSession.navigatorKey.currentContext!).routerDelegate.currentConfiguration.last.matchedLocation;

Future<void> tapNext(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390 * 3, 1800 * 3); // tall enough to build the Next button
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(await shell(const PersonalInformationScreen()));
  await settle(tester);
  final next = find.text('Next');
  await tester.ensureVisible(next);
  await tester.pump();
  await tester.tap(next);
  await settle(tester);
}

Future<void> unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 5));
}

void main() {
  setUpAll(bootHarness);
  setUp(() => FakeBackend.requests.clear());

  // 6 Nov app: Next saves the details on the phone only; the server gets them
  // with the documents. No partial profile update is sent from this screen.
  testWidgets('Next saves on the phone, calls no API, and opens Select Service', (tester) async {
    await tapNext(tester);
    expect(FakeBackend.requests.where((r) => r.path.endsWith('updateProfile_pat')), isEmpty);
    expect(AppSession.userId, 'sample-partner');
    expect(currentPath(), '/onboarding/select-service');
    final prefs = await tester.runAsync(SharedPreferences.getInstance);
    expect(prefs!.getString('user'), contains('"FirstName":"Ravi"'));
    await unmount(tester);
  });
}
