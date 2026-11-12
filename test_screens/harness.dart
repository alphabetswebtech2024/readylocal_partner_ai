// Screenshot harness for before/after UI comparisons.
//
// Renders real screens headlessly with real fonts and a fake in-process
// backend, so nothing ever calls the production API. All data below is
// SAMPLE DATA for screenshots only; none of it ships in the app.
//
// Run:  flutter test test_screens --update-goldens --dart-define=SHOTS=after
// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:convert';
import 'dart:io';

import 'package:gotask_partner/core/services/job_ring.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gotask_partner/app/providers/app_providers.dart';
import 'package:gotask_partner/core/di/service_locator.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';
import 'package:gotask_partner/core/provider/UserProvider.dart';
import 'package:gotask_partner/core/session/app_session.dart';
import 'package:gotask_partner/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

const shotsPhase = String.fromEnvironment('SHOTS', defaultValue: 'after');
const shotsLocale = String.fromEnvironment('LOCALE', defaultValue: 'en');

const _materialFonts =
    '/Users/vnspkiran/Documents/Codex/2026-09-20/th/work/flutter/bin/cache/artifacts/material_fonts/';

Future<void> _loadFamily(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final p in paths) {
    loader.addFont(Future.value(ByteData.view(File(p).readAsBytesSync().buffer)));
  }
  await loader.load();
}

/// Loads the fonts a real device would have: Roboto (Android system font,
/// used by the original screens), the app's bundled Noto Sans families, and
/// Material icons. flutter_test does not load pubspec fonts by itself.
Future<void> loadFonts() async {
  await _loadFamily('Roboto', [
    for (final w in ['Regular', 'Medium', 'Bold', 'Black', 'Light']) '${_materialFonts}Roboto-$w.ttf',
  ]);
  // Text with no font family falls back to the test font; on a phone it is the
  // system font, so load Roboto under the test font's name too.
  await _loadFamily('FlutterTest', [
    for (final w in ['Regular', 'Medium', 'Bold']) '${_materialFonts}Roboto-$w.ttf',
  ]);
  await _loadFamily('MaterialIcons', ['${_materialFonts}MaterialIcons-Regular.otf']);
  await _loadFamily('CupertinoIcons', [
    '${Platform.environment['HOME']}/.pub-cache/hosted/pub.dev/cupertino_icons-1.0.8/assets/CupertinoIcons.ttf',
  ].where((p) => File(p).existsSync()).toList());
  for (final fam in ['NotoSans', 'NotoSansTelugu']) {
    final files = [
      for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold']) 'assets/fonts/$fam-$w.ttf',
    ].where((p) => File(p).existsSync()).toList();
    if (files.isNotEmpty) await _loadFamily(fam, files);
  }
}

/// The original theme sets no font family, so on a device text uses the
/// system font. Tests fall back to a box font instead, so attach Roboto.
ThemeData shotTheme(ThemeData base) {
  final family = base.textTheme.bodyMedium?.fontFamily;
  if (family != null && family != 'Roboto') return base;
  return base.copyWith(
    textTheme: base.textTheme.apply(fontFamily: 'Roboto'),
    primaryTextTheme: base.primaryTextTheme.apply(fontFamily: 'Roboto'),
  );
}

// ---------------------------------------------------------------------------
// Sample data (screenshots only)
// ---------------------------------------------------------------------------

final sampleUser = {
  '_id': 'sample-partner',
  'FirstName': 'Ravi',
  'LastName': 'Kumar',
  'Gender': 'Male',
  'Email': 'ravi.kumar@example.com',
  'MobileNumber': '9876543210',
  'isProfileUpdated': true,
  'Address': 'Plot 12, Ayyappa Society',
  'City': 'Hyderabad',
  'State': 'Telangana',
  'PinCode': '500081',
  'skills': [],
};

Map<String, dynamic> _job(String id, String title, num amount, String status, String next, {num km = 2.4}) => {
      'JobID': 'job-$id',
      'RequestID': 'req-$id',
      'ServiceID': 'svc-$id',
      'RequestType': title,
      'Amount': amount,
      'ApointmentDate': '04 Nov 2026',
      'AppointmentTime': '04:00 PM',
      'DistanceKm': km,
      'PartnerRequestStatus': status,
      'NextStep': next,
    };

final sampleJobs = [
  _job('1', 'AC Service & Repair', 650, 'Ongoing', 'START_RIDE'),
  _job('2', 'Washing Machine Repair', 480, 'Started', 'REACHED', km: 5.1),
  _job('3', 'Plumbing', 480, 'Completed', 'COMPLETED', km: 1.2),
  _job('4', 'Electrician Visit', 350, 'Completed', 'COMPLETED', km: 3.8),
];

final samplePartnerDetails = {
  'Status': 'SUCCESS',
  'Data': {
    ...sampleUser,
    'HouseNo': '12',
    'jobStats': {'totalAssigned': 24, 'accepted': 2, 'rejected': 3, 'completed': 19, 'cancelled': 0, 'failed': 0},
    'earningDetails': {
      'todayEarnings': 1850,
      'todayJobs': 3,
      'weeklyEarnings': 9400,
      'weeklyJobs': 14,
      'monthlyEarnings': 32600,
      'monthlyJobs': 51,
    },
    'AcceptOrReject': sampleJobs,
  },
};

final sampleEarnings = {
  'Status': 'SUCCESS',
  'Data': {
    'todayEarnings': 1850,
    'weeklyEarnings': 9400,
    'monthlyEarnings': 32600,
    'availableBalance': 4200,
    'transactions': [
      {'_id': 't1', 'Notes': 'Bank Transaction', 'Amount': 3000, 'Status': 'PENDING', 'RequestedAt': '2026-11-02T18:45:00Z'},
      {'_id': 't2', 'Notes': 'Bank Transaction', 'Amount': 5000, 'Status': 'COMPLETED', 'RequestedAt': '2026-10-28T10:15:00Z'},
      {'_id': 't3', 'Notes': 'Bank Transaction', 'Amount': 2500, 'Status': 'COMPLETED', 'RequestedAt': '2026-10-20T09:30:00Z'},
    ],
  },
};

Map<String, dynamic> _module(String id, String code, String name, int order, {bool cat = true}) =>
    {'_id': id, 'Code': code, 'Name': name, 'Icon': '', 'Order': order, 'isActive': true, 'has_category': cat};

// Same formats as the live server (captured 2026-11-06).
final sampleModules = {
  'Status': 'SUCCESS',
  'modules': [
    _module('m1', 'HS', 'Home Services', 1, cat: false),
    _module('m2', 'PC', 'Personal Care Services', 2),
    _module('m3', 'PHYSIOTHERAPY', 'Physiotherapy', 3),
    _module('m4', 'NURSING', 'Nursing', 4),
    _module('m5', 'LS', 'Learning Services', 5),
    _module('m6', 'PUROHIT', 'Pandit / Purohit', 6),
    _module('m7', 'CAREGIVER', 'Caregiver', 7),
    _module('m8', 'PERSONAL_DRIVER', 'Personal Driver', 8),
  ],
};

final sampleBanks = {
  'statusCode': 200,
  'body': jsonEncode({
    'data': {
      'bankAccounts': [
        {'bankAccountId': 'b1', 'bankName': 'State Bank of India', 'accountName': 'Ravi Kumar', 'accountNumber': '00001234567890', 'ifsc': 'SBIN0000123'},
        {'bankAccountId': 'b2', 'bankName': 'HDFC Bank', 'accountName': 'Ravi Kumar', 'accountNumber': '50100987654321', 'ifsc': 'HDFC0000456'},
      ],
    },
  }),
};

final sampleRequestApi = {
  'JobId': 'req-1',
  'CustomerId': 'cust-1',
  'ServiceId': 'svc-1',
  'ServiceName': 'AC Service & Repair',
  'Services': [
    {'ServiceID': 'svc-1', 'Name': 'AC Service & Repair'},
  ],
  'AppointmentDate': '2026-11-04T00:00:00.000Z',
  'AppointmentTime': '04:00 PM - 05:00 PM',
  'CustomerName': 'Sneha',
  'CustomerPhone': '9000000001',
  'Address': 'Flat 402, Lake View Residency, Madhapur, Hyderabad',
  'Pricing': {'totalAmount': 650, 'finalAmount': 650},
  'Distance': '2.4',
  'NextStep': 'START_RIDE',
  'RequestStatus': 'Accepted',
  'Location': {
    'coordinates': [78.3915, 17.4483],
  },
};

/// Answers every request in-process. Unknown endpoints get an empty success.
class FakeBackend extends Interceptor {
  static final Map<String, Object> responses = {
    'getPartnerDetails': samplePartnerDetails,
    'getEarningsSummary': sampleEarnings,
    'getEarningDetails': sampleEarnings,
    'getModules': sampleModules,
    'listBankAccounts': sampleBanks,
    'getRegistrationFees': {
      'Status': 'SUCCESS',
      'RegistrationFees': [
        {'level': 'Module', 'refId': 'HS', 'amount': 0, 'isActive': true},
      ],
    },
    'getRequestDetails_pat': {'Status': 'SUCCESS', 'Data': sampleRequestApi},
  };

  /// Every request the app made, in order, for regression assertions.
  static final List<RequestOptions> requests = [];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    requests.add(options);
    final key = options.uri.pathSegments.isEmpty ? '' : options.uri.pathSegments.last;
    handler.resolve(Response(
      requestOptions: options,
      statusCode: 200,
      data: responses[key] ?? {'Status': 'SUCCESS', 'Data': <String, dynamic>{}},
    ));
  }
}

bool _booted = false;

/// One-time setup shared by every screen test.
Future<void> bootHarness() async {
  if (_booted) return;
  _booted = true;
  TestWidgetsFlutterBinding.ensureInitialized();
  JobRing.enabled = false;
  setupFirebaseCoreMocks();
  await Firebase.initializeApp();
  // Platform plugins the screens touch on start-up answer "nothing".
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  for (final name in [
    'flutter.baseflow.com/geolocator',
    'flutter.baseflow.com/geolocator_android',
    'flutter.baseflow.com/permissions/methods',
    'razorpay_flutter',
    'plugins.flutter.io/firebase_analytics',
    'plugins.flutter.io/firebase_crashlytics',
    'plugins.flutter.io/firebase_messaging',
    'dexterous.com/flutter/local_notifications',
    'dev.fluttercommunity.plus/package_info',
    'plugins.it_nomads.com/flutter_secure_storage',
    'plugins.flutter.io/path_provider',
    for (var i = 0; i < 4; i++) 'plugins.flutter.io/google_maps_$i',
  ]) {
    messenger.setMockMethodCallHandler(MethodChannel(name), (_) async => null);
  }
  // Pigeon-based Firebase Analytics calls: reply "success, no value".
  const pigeon = 'dev.flutter.pigeon.firebase_analytics_platform_interface.FirebaseAnalyticsHostApi.';
  for (final method in ['setUserId', 'setUserProperty', 'logEvent', 'setCurrentScreen']) {
    messenger.setMockMessageHandler(
      '$pigeon$method',
      (_) async => const StandardMessageCodec().encodeMessage(<Object?>[null]),
    );
  }
  // Native views (Google Map, WebView) render as empty boxes in tests.
  messenger.setMockMethodCallHandler(SystemChannels.platform_views, (call) async {
    return call.method == 'create' ? 0 : null;
  });
  SharedPreferences.setMockInitialValues({
    'user': '{"_id":"sample-partner","FirstName":"Ravi","LastName":"Kumar","Gender":"Male",'
        '"Email":"ravi.kumar@example.com","MobileNumber":"9876543210","isProfileUpdated":true,'
        '"Address":"Plot 12, Ayyappa Society","City":"Hyderabad","State":"Telangana","PinCode":"500081","skills":[]}',
    'auth_token': 'sample-token',
    'registrationFee': 499.0,
  });
  await loadFonts();
  await ServiceLocator.init();
  ServiceLocator.apiClient.dio.interceptors.insert(0, FakeBackend());
}

/// Builds the app shell around one screen, the way main.dart does.
Future<Widget> shell(Widget screen) async {
  final userProvider = UserProvider();
  await userProvider.loadUserFromPrefs();
  if (userProvider.userOrNull != null) AppSession.setUser(userProvider.userOrNull);
  final router = GoRouter(
    navigatorKey: AppSession.navigatorKey,
    initialLocation: '/shot',
    routes: [
      GoRoute(path: '/shot', builder: (_, _) => screen),
      GoRoute(path: '/:rest(.*)', builder: (_, _) => const Scaffold()),
    ],
  );
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: userProvider),
      ChangeNotifierProvider.value(value: LocaleProvider()..setLocale(const Locale(shotsLocale))),
      ...appProviders,
    ],
    child: Sizer(
      builder: (context, orientation, deviceType) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: shotTheme(AppTheme.lightTheme),
        routerConfig: router,
        locale: const Locale(shotsLocale),
        supportedLocales: LocaleProvider.supported,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    ),
  );
}
