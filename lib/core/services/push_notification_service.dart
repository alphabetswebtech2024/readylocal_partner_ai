import 'dart:convert';
import 'dart:typed_data';
import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/widgets.dart' show AppLifecycleState, Color, Locale, WidgetsBinding, WidgetsBindingObserver;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/generated/app_localizations.dart';
import '../di/service_locator.dart';
import 'job_closed.dart';
import 'job_ring.dart';
import '../utils/AppConstants.dart';
import '../utils/Observable.dart';
import '../session/app_session.dart';
import '../../features/notifications/presentation/widgets/notification_job_service.dart';

/// How long a job alert keeps ringing at most (same as kJobRequestWindowSeconds).
/// It stops earlier when the partner answers or the server says the job is closed.
const int kJobRingSeconds = kJobRequestWindowSeconds;

/// Runs in a background isolate when a push arrives while the app is in the
/// background or not running. Pushes that carry a `notification` block are
/// already shown by the system; data-only job pushes were previously dropped
/// here, so they are now shown as a high-priority alert. Tapping it opens the
/// app and the job popup.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  developer.log('Handling a background message ${message.messageId}');
  // Another partner took the job, or it was cancelled: stop the ring here too.
  final closedId = JobClosed.requestIdOf(PushNotificationService.parseNotificationData(message));
  if (closedId != null) {
    await PushNotificationService.cancelJobAlert(closedId);
    return;
  }
  if (message.notification != null) return;
  await PushNotificationService.showJobAlert(message);
}

/// Centralized Push Notification Service handling FCM, Local Notifications, and Audio alerts.
class PushNotificationService {
  PushNotificationService._();

  static AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  /// Channel for new job requests: highest importance (heads-up on the lock
  /// screen) and the app's own job sound (android/app/src/main/res/raw).
  /// It is also the manifest default for pushes that name no channel.
  static const AndroidNotificationChannel jobChannel = AndroidNotificationChannel(
    'job_requests',
    'New job requests',
    description: 'Alerts for new job requests from customers.',
    importance: Importance.max,
    sound: RawResourceAndroidNotificationSound('notification_sound'),
  );

  /// White silhouette of the logo: Android draws status-bar icons as a mask,
  /// so a full-colour launcher icon would show as a white square.
  static const String _statusBarIcon = 'ic_notification';
  static const Color _brandColor = Color(0xFF1F3E7F);

  static const InitializationSettings _initSettings = InitializationSettings(
    android: AndroidInitializationSettings(_statusBarIcon),
    iOS: DarwinInitializationSettings(
      // Asked for in registerNotificationListeners, not while the plugin starts.
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    ),
  );

  static Future<void> _createChannels() async {
    final android = localNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(channel);
    await android?.createNotificationChannel(jobChannel);
  }

  /// Shows a job alert for a data-only push (background or app not running).
  static Future<void> showJobAlert(RemoteMessage message) async {
    try {
      final data = parseNotificationData(message) ?? <String, dynamic>{};
      await localNotificationsPlugin.initialize(settings: _initSettings);
      await _createChannels();

      // The background isolate has no app state, so read the saved language.
      String code = 'en';
      try {
        code = (await SharedPreferences.getInstance()).getString('app_language') ?? 'en';
      } catch (_) {}
      final l10n = lookupAppLocalizations(Locale(code == 'te' ? 'te' : 'en'));

      String text(List<String> keys) {
        for (final k in keys) {
          final v = data[k] ?? message.data[k];
          if (v != null && v.toString().trim().isNotEmpty) return v.toString().trim();
        }
        return '';
      }

      final service = text(['ServiceName', 'serviceName', 'jobTitle']);
      final where = text(['Address', 'SourceAddress', 'address']);
      final title = text(['title', 'Title']).isNotEmpty ? text(['title', 'Title']) : l10n.pushNewJobTitle;
      final body = text(['body', 'Body']).isNotEmpty
          ? text(['body', 'Body'])
          : [service, where].where((e) => e.isNotEmpty).join(' • ');

      // Ring only while the job can still be answered.
      final sent = message.sentTime?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch;
      final ringMs = (kJobRingSeconds * 1000 - (DateTime.now().millisecondsSinceEpoch - sent))
          .clamp(5000, kJobRingSeconds * 1000);

      await localNotificationsPlugin.show(
        id: JobClosed.notificationIdFor(
            text(['RequestID', 'requestId']).isNotEmpty ? text(['RequestID', 'requestId']) : (message.messageId ?? title)),
        title: title,
        body: body.isEmpty ? l10n.pushNewJobBody : body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            jobChannel.id,
            jobChannel.name,
            channelDescription: jobChannel.description,
            importance: Importance.max,
            priority: Priority.max,
            sound: jobChannel.sound,
            category: AndroidNotificationCategory.message,
            visibility: NotificationVisibility.public,
            ticker: title,
            // Android's insistent flag: the sound repeats until the partner opens
            // or dismisses the alert, and timeoutAfter ends it when the job expires.
            additionalFlags: Int32List.fromList(const [4]),
            timeoutAfter: ringMs,
            icon: _statusBarIcon,
            color: _brandColor,
          ),
          iOS: const DarwinNotificationDetails(presentAlert: true, presentSound: true),
        ),
        payload: jsonEncode(data),
      );
    } catch (e) {
      developer.log('showJobAlert error: $e');
    }
  }

  /// Removes a job alert (and its ring) for a job that is no longer open.
  static Future<void> cancelJobAlert(String requestId) async {
    try {
      await localNotificationsPlugin.initialize(settings: _initSettings);
      await localNotificationsPlugin.cancel(id: JobClosed.notificationIdFor(requestId));
    } catch (e) {
      developer.log('cancelJobAlert error: $e');
    }
  }

  /// One short alert on the job channel, so the partner can hear that alerts work.
  static Future<void> showTestAlert({required String title, required String body}) async {
    try {
      await _createChannels();
      await localNotificationsPlugin.show(
        id: 7001,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            jobChannel.id,
            jobChannel.name,
            channelDescription: jobChannel.description,
            importance: Importance.max,
            priority: Priority.max,
            sound: jobChannel.sound,
            icon: _statusBarIcon,
            color: _brandColor,
            timeoutAfter: 15000,
          ),
          iOS: const DarwinNotificationDetails(presentAlert: true, presentSound: true),
        ),
      );
    } catch (e) {
      developer.log('showTestAlert error: $e');
    }
  }

  /// Which partner and token the server has confirmed since the app started.
  static String _confirmedToken = '';
  static bool _tokenUploadRunning = false;

  /// Sends the push token to the server (same API as Home) when a partner is
  /// signed in, so the server never keeps a stale token.
  static Future<void> uploadToken(String token) async {
    deviceId = token;
    await ensureTokenOnServer();
  }

  /// Without the right token on the server no job alert can reach this phone,
  /// so a failed upload is retried, and tried again whenever the app returns to
  /// the foreground or the network comes back. Does nothing once confirmed.
  static Future<void> ensureTokenOnServer({
    List<Duration> retryAfter = const [
      Duration(seconds: 5),
      Duration(seconds: 15),
      Duration(seconds: 45),
      Duration(minutes: 2),
    ],
    @visibleForTesting Future<bool> Function(String partnerId, String token)? send,
  }) async {
    if (_tokenUploadRunning) return;
    _tokenUploadRunning = true;
    try {
      for (var attempt = 0; attempt <= retryAfter.length; attempt++) {
        final partnerId = AppSession.userId;
        final token = deviceId;
        final key = '$partnerId|$token';
        if (partnerId.isEmpty || token.isEmpty || key == _confirmedToken) return;
        try {
          final ok = await (send ?? _sendToken)(partnerId, token);
          if (ok) {
            _confirmedToken = key;
            return;
          }
        } catch (e) {
          developer.log('uploadToken error: $e');
        }
        if (attempt < retryAfter.length) await Future<void>.delayed(retryAfter[attempt]);
      }
    } finally {
      _tokenUploadRunning = false;
    }
  }

  static Future<bool> _sendToken(String partnerId, String token) async {
    final result = await ServiceLocator.updateDeviceTokenUseCase(partnerId: partnerId, deviceToken: token);
    return result.isSuccess;
  }

  @visibleForTesting
  static void resetTokenState() => _confirmedToken = '';

  static final FlutterLocalNotificationsPlugin localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _listenersRegistered = false;

  /// Parses raw FCM RemoteMessage into a Map<String, dynamic>.
  static Map<String, dynamic>? parseNotificationData(RemoteMessage message) {
    try {
      Map<String, dynamic>? parsed;
      if (message.data.containsKey('Data')) {
        final rawData = message.data['Data'];
        parsed = rawData is String ? jsonDecode(rawData) : Map<String, dynamic>.from(rawData);
      } else {
        parsed = Map<String, dynamic>.from(message.data);
      }

      if (message.sentTime != null) {
        parsed?['sentTime'] = message.sentTime!.millisecondsSinceEpoch;
      }

      return parsed;
    } catch (e) {
      developer.log('parseNotificationData error: $e');
      return null;
    }
  }

  /// Initializes notification channels, local notifications plugin, and checks for terminated launch.
  static Future<void> init() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _createChannels();

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Check if app was opened via terminated state notification
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      developer.log("Terminated state notification caught: ${initialMessage.data}");
      AppSession.pendingNotificationData = parseNotificationData(initialMessage);
    }

    // Or opened by tapping a job alert this app showed while it was not running.
    try {
      final launch = await localNotificationsPlugin.getNotificationAppLaunchDetails();
      final payload = launch?.notificationResponse?.payload;
      if (launch?.didNotificationLaunchApp == true &&
          payload != null &&
          payload.isNotEmpty &&
          AppSession.pendingNotificationData == null) {
        final decoded = jsonDecode(payload);
        if (decoded is Map && decoded.isNotEmpty) {
          AppSession.pendingNotificationData = Map<String, dynamic>.from(decoded);
        }
      }
    } catch (e) {
      developer.log('Launch details error: $e');
    }
  }

  /// Registers notification listeners, requests permissions, and binds local notification callbacks.
  static Future<void> registerNotificationListeners() async {
    if (_listenersRegistered || Firebase.apps.isEmpty) return;
    _listenersRegistered = true;

    try {
      await localNotificationsPlugin.initialize(
        settings: _initSettings,
        onDidReceiveNotificationResponse: (response) {
          if (response.payload != null) {
            try {
              final data = jsonDecode(response.payload!) as Map<String, dynamic>;
              Map<String, dynamic>? jobData;
              if (data.containsKey('Data')) {
                final raw = data['Data'];
                jobData = raw is String ? jsonDecode(raw) as Map<String, dynamic> : Map<String, dynamic>.from(raw);
              } else {
                jobData = data;
              }
              NotificationJobService.showJobPopupFromNotification(jobData);
            } catch (e) {
              developer.log('Payload parse error: $e');
            }
          }
        },
      );
    } catch (e) {
      developer.log('Local notifications init error: $e');
    }

    // Listen before asking for permission: a job arriving while the permission
    // dialog is open was lost, and a partner who declined the system
    // permission never got the in-app job popup at all, even with the app open.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      developer.log("onMessage Push Notification Details: ${message.toMap()}");

      Observable.instance.notifyObservers(["_HomeScreenState"], notifyName: "Push Received", map: {});

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      final jobData = parseNotificationData(message);

      final closedId = JobClosed.requestIdOf(jobData);
      if (closedId != null) {
        cancelJobAlert(closedId);
        JobClosed.announce(closedId);
        return;
      }

      if (notification != null && android != null) {
        localNotificationsPlugin
            .show(
              id: notification.hashCode,
              title: notification.title,
              body: notification.body,
              notificationDetails: NotificationDetails(
                android: AndroidNotificationDetails(
                  channel.id,
                  channel.name,
                  channelDescription: channel.description,
                  icon: _statusBarIcon,
                  color: _brandColor,
                ),
              ),
              payload: jsonEncode(jobData),
            )
            .catchError((e) => developer.log('Foreground alert error: $e'));
      }

      if (jobData != null) {
        JobRing.pushArrived();
        NotificationJobService.showJobPopupFromNotification(jobData);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      developer.log("onMessageOpenedApp Push Notification Details: ${message.toMap()}");
      final jobData = parseNotificationData(message);
      if (jobData != null) NotificationJobService.showJobPopupFromNotification(jobData);
    });

    WidgetsBinding.instance.addObserver(_TokenWatcher());
    try {
      Connectivity().onConnectivityChanged.listen((_) => ensureTokenOnServer(), onError: (_) {});
    } catch (_) {}

    // Firebase rotates tokens; send the new one so pushes keep arriving.
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      deviceId = token;
      uploadToken(token);
    }, onError: (e) => developer.log('Token refresh error: $e'));

    _fetchToken();

    try {
      await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true);
    } catch (e) {
      developer.log('Permission request error: $e');
    }
  }

  /// A phone that starts offline can't get a token on the first try. Without a
  /// token on the server no job alert can reach it, so keep trying with growing
  /// gaps for about ten minutes.
  static Future<void> _fetchToken({int attempt = 0}) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        deviceId = token;
        await uploadToken(token);
        await FirebaseMessaging.instance.subscribeToTopic("GO-Task-Partner-Flutter-App");
        return;
      }
    } catch (e) {
      developer.log('Error getting token: $e');
    }
    if (attempt < 5) {
      await Future<void>.delayed(Duration(seconds: 20 * (1 << attempt)));
      await _fetchToken(attempt: attempt + 1);
    }
  }
}

class _TokenWatcher with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) PushNotificationService.ensureTokenOnServer();
  }
}
