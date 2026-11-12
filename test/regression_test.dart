// Regression tests for the UI modernisation: they pin down behaviour that
// must be identical before and after the redesign (API payloads, navigation,
// validation rules, popup flow) and check the English/Telugu resources.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gotask_partner/core/di/service_locator.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';
import 'package:gotask_partner/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:gotask_partner/core/session/app_session.dart';
import 'package:gotask_partner/features/earnings/presentation/screens/earnings_screen.dart';
import 'package:gotask_partner/features/home/presentation/screens/home_screen.dart';
import 'package:gotask_partner/features/login/presentation/screens/login_screen.dart';
import 'package:gotask_partner/features/notifications/domain/entities/notification_popup_config.dart';
import 'package:gotask_partner/features/notifications/presentation/providers/notification_popup_controller.dart';
import 'package:gotask_partner/features/notifications/presentation/widgets/notification_popup_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_screens/harness.dart';

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Location of the top-most route, including ones opened with `push`.
String currentPath() =>
    GoRouter.of(AppSession.navigatorKey.currentContext!).routerDelegate.currentConfiguration.last.matchedLocation;

Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(await shell(screen));
  await settle(tester);
}

Future<void> unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 5));
}

void main() {
  setUpAll(bootHarness);
  setUp(() => FakeBackend.requests.clear());

  group('Login (workflow unchanged)', () {
    testWidgets('rejects numbers that do not start with 6-9, same rule as before', (tester) async {
      AppSession.registerIntent = true;
      await pumpScreen(tester, const LoginScreen());
      await tester.enterText(find.byType(TextFormField), '5123456789');
      await tester.tap(find.text('Become a Partner'));
      await tester.pump();
      expect(find.text('Indian numbers must start with 6, 7, 8, or 9'), findsOneWidget);
      expect(FakeBackend.requests, isEmpty, reason: 'invalid numbers must not call the API');
      await unmount(tester);
    });

    // Register and Login share one screen and one OTP request (6 Nov app); only the words differ.
    for (final (register, button, title) in [(true, 'Become a Partner', 'Register'), (false, 'Send OTP', 'Login')]) {
      testWidgets('$title: sends the same OTP payload and opens OTP screen', (tester) async {
        AppSession.registerIntent = register;
        await pumpScreen(tester, const LoginScreen());
        expect(find.text(title), findsOneWidget);
        await tester.enterText(find.byType(TextFormField), '9876543210');
        await tester.tap(find.text(button));
        await settle(tester);
        final otp = FakeBackend.requests.singleWhere((r) => r.path.endsWith('partnerOTP'));
        expect(otp.method, 'POST');
        expect(otp.data, {'MobileNumber': '+919876543210'});
        expect(currentPath(), '/auth/otp-verify');
        await unmount(tester);
      });
    }
  });

  group('Home (workflow unchanged)', () {
    testWidgets('online toggle posts the same partnerOnOrOff payload', (tester) async {
      await pumpScreen(tester, const HomeScreen());
      FakeBackend.requests.clear();
      await tester.tap(find.text('Offline'));
      await settle(tester);
      final call = FakeBackend.requests.firstWhere((r) => r.path.endsWith('partnerOnOrOff'));
      expect(call.data, {'partnerID': 'sample-partner', 'status': 'ONLINE'}); // 6 Nov app
      expect(find.text('Online'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('period selector still drives Daily/Weekly/Monthly amounts', (tester) async {
      await pumpScreen(tester, const HomeScreen());
      expect(find.text('₹1850'), findsOneWidget);
      await tester.tap(find.text('Daily'));
      await settle(tester);
      await tester.tap(find.text('Weekly').last);
      await settle(tester);
      expect(find.text('₹9400'), findsOneWidget);
      expect(find.text('14 jobs this week'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('job tabs and View All links go to the same places', (tester) async {
      await pumpScreen(tester, const HomeScreen());
      expect(find.text('AC Service & Repair'), findsOneWidget);
      await tester.tap(find.text('Completed').last);
      await settle(tester);
      expect(find.text('Plumbing'), findsOneWidget);
      expect(find.text('AC Service & Repair'), findsNothing);

      await tester.tap(find.text('View All').first);
      await settle(tester);
      expect(currentPath(), '/earnings');
      await unmount(tester);
    });

    testWidgets('tapping a job loads details and opens customer details', (tester) async {
      await pumpScreen(tester, const HomeScreen());
      await tester.tap(find.text('More Details').first);
      await settle(tester);
      expect(FakeBackend.requests.any((r) => r.path.endsWith('getRequestDetails_pat')), isTrue);
      expect(currentPath(), '/jobs/customer-details');
      await unmount(tester);
    });
  });

  group('Earnings (workflow unchanged)', () {
    testWidgets('withdraw button opens withdraw screen; tabs filter transactions', (tester) async {
      await pumpScreen(tester, const EarningsScreen());
      expect(find.text('₹4,200'), findsOneWidget);
      expect(find.text('₹3,000'), findsOneWidget); // pending tab
      await tester.tap(find.text('Completed'));
      await settle(tester);
      expect(find.text('₹5,000'), findsOneWidget);
      expect(find.text('₹3,000'), findsNothing);

      await tester.tap(find.text('Send withdraw request'));
      await settle(tester);
      expect(currentPath(), '/withdraw');
      await unmount(tester);
    });
  });

  group('Job request popup (flow unchanged)', () {
    Future<NotificationPopupController> pumpPopup(
      WidgetTester tester, {
      required VoidCallback onAccept,
      required VoidCallback onReject,
    }) async {
      final controller = NotificationPopupController()
        ..open(const PopupConfig(
          requestId: 'req-1',
          customerName: 'Sneha',
          fullAddress: '',
          formattedDate: '04 Nov 2026',
          timeSlot: '04:00 PM',
          status: 'Pending',
          mobile: '',
          paymentStatus: '',
          services: [
            {'Name': 'AC Service & Repair'},
          ],
          pricing: {'finalAmount': 650},
          apiData: {'Distance': '2.4'},
        ));
      await pumpScreen(
        tester,
        Scaffold(
          body: NotificationPopup(
            controller: controller,
            onAcceptConfirmed: onAccept,
            onRejectReasonSubmitted: onReject,
          ),
        ),
      );
      return controller;
    }

    testWidgets('buttons keep their order: Accept, Reject, Details', (tester) async {
      final c = await pumpPopup(tester, onAccept: () {}, onReject: () {});
      final accept = tester.getCenter(find.text('Accept'));
      final reject = tester.getCenter(find.text('Reject'));
      final details = tester.getCenter(find.text('Details'));
      expect(accept.dx < reject.dx && reject.dx < details.dx, isTrue);
      c.close();
      await unmount(tester);
    });

    testWidgets('Accept asks for confirmation, then calls accept once', (tester) async {
      var accepted = 0;
      final c = await pumpPopup(tester, onAccept: () => accepted++, onReject: () {});
      await tester.tap(find.text('Accept'));
      await settle(tester);
      expect(find.text('Are you sure you want to accept this job?'), findsOneWidget);
      expect(accepted, 0);
      await tester.tap(find.text('Yes'));
      await settle(tester);
      expect(accepted, 1);
      c.close();
      await unmount(tester);
    });

    testWidgets('Reject goes confirm -> reason -> submit', (tester) async {
      var rejected = 0;
      final c = await pumpPopup(tester, onAccept: () {}, onReject: () => rejected++);
      await tester.tap(find.text('Reject'));
      await settle(tester);
      await tester.tap(find.text('Yes'));
      await settle(tester);
      expect(find.text('Rejection Reason'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Too far');
      await tester.tap(find.text('Submit'));
      await settle(tester);
      expect(rejected, 1);
      expect(c.rejectReasonController.text, 'Too far');
      c.close();
      await unmount(tester);
    });
  });

  group('Routing safety', () {
    test('job routes without data redirect home instead of crashing', () async {
      final source = File('lib/app/router/app_router.dart').readAsStringSync();
      for (final route in ['completedJobOverview', 'customerDetails', 'jobOverview']) {
        final block = source.substring(source.indexOf('path: AppRoutes.$route,'));
        expect(block.substring(0, 300), contains('redirect:'), reason: route);
      }
    });
  });

  group('Notifications', () {
    test('no hard-coded sample notifications are shown', () async {
      final list = await NotificationRemoteDataSourceImpl(ServiceLocator.apiService).getNotifications();
      expect(list, isEmpty);
    });
  });

  group('Language', () {
    test('choice is persisted and restored', () async {
      SharedPreferences.setMockInitialValues({});
      await LocaleProvider().setLocale(const Locale('te'));
      final restored = LocaleProvider();
      await restored.load();
      expect(restored.locale.languageCode, 'te');
    });

    test('Telugu ARB has every English key with the same placeholders', () {
      final en = jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync()) as Map<String, dynamic>;
      final te = jsonDecode(File('lib/l10n/app_te.arb').readAsStringSync()) as Map<String, dynamic>;
      final placeholder = RegExp(r'\{(\w+)[,}]');
      for (final key in en.keys.where((k) => !k.startsWith('@'))) {
        expect(te.containsKey(key), isTrue, reason: 'missing te key $key');
        final enP = placeholder.allMatches(en[key] as String).map((m) => m.group(1)).toSet();
        final teP = placeholder.allMatches(te[key] as String).map((m) => m.group(1)).toSet();
        expect(teP, enP, reason: 'placeholder mismatch in $key');
      }
    });

    test('Telugu strings resolve without a BuildContext', () {
      final l10n = lookupAppLocalizations(const Locale('te'));
      expect(l10n.homeEarnings, 'సంపాదన');
      expect(l10n.homeJobsToday(3), 'ఈరోజు 3 పనులు');
    });
  });
}
