import 'dart:async';
import 'dart:developer' as developer;
import 'dart:isolate';
import 'dart:ui' show PlatformDispatcher;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'app/providers/app_providers.dart';
import 'app/router/app_router.dart';
import 'core/design/app_colors.dart';
import 'core/design/app_widgets.dart' show AppWidgetErrorBox;
import 'core/design/offline_banner.dart';
import 'core/di/service_locator.dart';
import 'core/localization/locale_provider.dart';
import 'core/provider/UserProvider.dart';
import 'core/services/push_notification_service.dart';
import 'core/session/app_session.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

// Re-export session globals and services for full backward compatibility during migration:
export 'core/session/app_session.dart';
export 'core/services/location_service.dart' show getDynamicDistance;
export 'features/notifications/presentation/widgets/notification_job_service.dart'
    show getRequestDetailsMethod, showJobPopupFromNotification;

final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
final Locale gLocale = Locale(Intl.getCurrentLocale());

/// Sends an error to Crashlytics when Firebase started; never throws.
void _report(Object error, StackTrace? stack, {bool fatal = false}) {
  developer.log('Unhandled error: $error', error: error, stackTrace: stack);
  if (Firebase.apps.isEmpty) return;
  try {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: fatal);
  } catch (_) {}
}

/// Runs one startup step. A failing or stuck step (slow Firebase, corrupt
/// storage) is logged and skipped, so the app always reaches its first screen.
Future<bool> _step(String name, Future<void> Function() run, {Duration limit = const Duration(seconds: 8)}) async {
  try {
    await run().timeout(limit);
    return true;
  } catch (e, s) {
    developer.log('Startup step "$name" failed: $e', error: e, stackTrace: s);
    return false;
  }
}

Future<void> main() async {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Phones with 2 GB RAM: keep decoded images to a small budget (Flutter's
      // default is 100 MB). Images are re-decoded from disk cache when needed.
      PaintingBinding.instance.imageCache
        ..maximumSize = 120
        ..maximumSizeBytes = 48 * 1024 * 1024;

      // A broken widget shows a small notice instead of a red/grey screen.
      ErrorWidget.builder = (details) => const AppWidgetErrorBox();

      SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      // 1. Initialize Dependency Injection & Secure Storage
      await _step('services', ServiceLocator.init);

      // 2. Initialize Firebase
      final firebaseReady = await _step(
        'firebase',
        () => Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
        limit: const Duration(seconds: 12),
      );
      if (firebaseReady) {
        FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
        PlatformDispatcher.instance.onError = (error, stack) {
          _report(error, stack, fatal: true);
          return true;
        };

        // 3. Initialize Push Notifications & FCM Channels
        await _step('push', PushNotificationService.init);
      }

      // 4. System UI Overlay Style. Dark icons suit the app's white screens;
      // the blue headers (Home, Login) switch to light icons themselves.
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );

      // 5. Load User from storage into session
      final userProvider = UserProvider();
      await _step('user', () async {
        await userProvider.loadUserFromPrefs();
        if (userProvider.userOrNull != null) {
          AppSession.setUser(userProvider.userOrNull);
        }
      });

      // Wi-Fi/mobile switches start a fresh connection pool.
      await _step('network', () async => ServiceLocator.apiClient.watchNetworkChanges());

      // Saved language (English by default).
      final localeProvider = LocaleProvider();
      await _step('language', localeProvider.load);

      final router = AppRouter.createRouter(
        userProvider,
        observers: [
          if (firebaseReady) FirebaseAnalyticsObserver(analytics: analytics),
        ],
      );

      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: userProvider),
            ChangeNotifierProvider.value(value: localeProvider),
            ...appProviders,
          ],
          child: MyApp(router: router),
        ),
      );
    },
    (dynamic error, dynamic stack) => _report(error, stack as StackTrace?),
  );

  Isolate.current.addErrorListener(
    RawReceivePort((pair) async {
      final List<dynamic> errorAndStacktrace = pair;
      _report(
        errorAndStacktrace.first as Object,
        errorAndStacktrace.last == null ? null : StackTrace.fromString(errorAndStacktrace.last.toString()),
      );
    }).sendPort,
  );
}

class MyApp extends StatefulWidget {
  final GoRouter? router;
  const MyApp({super.key, this.router});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = widget.router ?? AppRouter.createRouter(UserProvider());
    PushNotificationService.registerNotificationListeners();
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return OverlaySupport.global(
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'ReadyLocal Partner',
            routerConfig: _router,
            locale: context.watch<LocaleProvider>().locale,
            supportedLocales: LocaleProvider.supported,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.lightTheme,
            themeMode: ThemeMode.system,
            builder: (context, child) {
              final mediaQuery = MediaQuery.of(context);
              return MediaQuery(
                data: mediaQuery.copyWith(textScaler: const TextScaler.linear(1.0)),
                // White behind the phone's navigation bar, which was showing as a black band.
                child: ColoredBox(
                  color: AppColors.surface,
                  child: SafeArea(
                    top: false,
                    bottom: true,
                    child: OfflineBanner(child: child ?? const SizedBox.shrink()),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}