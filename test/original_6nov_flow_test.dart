// Workflow copied from the developer's 6 Nov 2026 app (COMPARISON_6NOV.md).
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gotask_partner/app/providers/app_providers.dart';
import 'package:gotask_partner/app/router/app_router.dart';
import 'package:gotask_partner/app/router/route_names.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';
import 'package:gotask_partner/core/provider/UserProvider.dart';
import 'package:gotask_partner/core/session/app_session.dart';
import 'package:gotask_partner/features/medical_setup/presentation/screens/medical_setup_screen.dart';
import 'package:gotask_partner/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../test_screens/harness.dart';

Map<String, dynamic> _user({bool documents = false}) => {
      '_id': 'sample-partner',
      'FirstName': 'Ravi',
      'LastName': 'Kumar',
      'Gender': 'Male',
      'Email': 'ravi.kumar@example.com',
      'MobileNumber': '9876543210',
      'isProfileUpdated': true,
      'Address': 'Plot 12',
      'City': 'Hyderabad',
      'State': 'Telangana',
      'PinCode': '500081',
      'skills': [
        {'moduleId': 'hs', 'moduleName': 'Home Services'},
      ],
      if (documents) 'AadharPicBack': 'https://example.com/back.jpg',
    };

List<String> _stack() => GoRouter.of(AppSession.navigatorKey.currentContext!)
    .routerDelegate
    .currentConfiguration
    .matches
    .map((m) => m.matchedLocation)
    .toList();

Future<void> _openApp(WidgetTester tester, Map<String, dynamic> user) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({
    'user': jsonEncode(user),
    'auth_token': 'sample-token',
    'registrationFee': 499.0,
  });
  final userProvider = UserProvider();
  await userProvider.loadUserFromPrefs();
  final router = AppRouter.createRouter(userProvider);
  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: userProvider),
      ChangeNotifierProvider.value(value: LocaleProvider()..setLocale(const Locale('en'))),
      ...appProviders,
    ],
    child: Sizer(
      builder: (context, orientation, deviceType) => MaterialApp.router(
        routerConfig: router,
        locale: const Locale('en'),
        supportedLocales: LocaleProvider.supported,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    ),
  ));
  for (var i = 0; i < 40; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 25)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _back(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _close(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 5));
}

void main() {
  setUpAll(bootHarness);

  testWidgets('reopening with a service chosen: Documents, Back goes to Select Service, then Personal Info',
      (tester) async {
    await _openApp(tester, _user());
    expect(_stack(), [AppRoutes.personalInfo, AppRoutes.selectService, AppRoutes.uploadDocs]);
    await _back(tester);
    expect(_stack().last, AppRoutes.selectService);
    await _back(tester);
    expect(_stack().last, AppRoutes.personalInfo);
    await _close(tester);
  });

  testWidgets('reopening with documents but fee unpaid: Fee screen with the earlier steps behind it',
      (tester) async {
    await _openApp(tester, _user(documents: true));
    expect(_stack(), [AppRoutes.personalInfo, AppRoutes.selectService, AppRoutes.uploadDocs, AppRoutes.activationFee]);
    await _back(tester);
    expect(_stack().last, AppRoutes.uploadDocs);
    await _close(tester);
  });

  testWidgets('Physiotherapy/Nursing/Caregiver setup has no duration or rate section', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(await shell(const MedicalSetupScreen(
      args: {'moduleId': 'nursing', 'moduleCode': 'NURSING', 'ModuleName': 'Nursing'},
    )));
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byType(CheckboxListTile), findsNothing);
    expect(find.textContaining('Rate'), findsNothing);
    expect(find.text('Hourly'), findsNothing);
    await _close(tester);
  });
}
