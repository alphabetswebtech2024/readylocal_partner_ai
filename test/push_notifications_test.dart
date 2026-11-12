// Background job alerts and push token upload. The notification plugin is
// mocked at its platform channel; no real push is sent.
import 'package:gotask_partner/features/notifications/presentation/providers/notification_popup_controller.dart';
import 'package:gotask_partner/features/notifications/domain/entities/notification_popup_config.dart';
import 'package:gotask_partner/core/services/job_closed.dart';
import 'package:gotask_partner/core/services/job_ring.dart';
import 'package:gotask_partner/core/utils/AppConstants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotask_partner/core/services/push_notification_service.dart';
import 'package:gotask_partner/core/session/app_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_screens/harness.dart';

const _channel = MethodChannel('dexterous.com/flutter/local_notifications');
final List<MethodCall> calls = [];

RemoteMessage jobPush({RemoteNotification? notification}) => RemoteMessage(
      messageId: 'm1',
      notification: notification,
      data: const {
        'RequestID': 'req-42',
        'ServiceName': 'AC Service & Repair',
        'Address': 'Madhapur, Hyderabad',
      },
    );

void main() {
  setUpAll(() async {
    await bootHarness();
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    AndroidFlutterLocalNotificationsPlugin.registerWith();
  });
  tearDownAll(() => debugDefaultTargetPlatformOverride = null);

  setUp(() async {
    calls.clear();
    FakeBackend.requests.clear();
    (await SharedPreferences.getInstance()).remove('app_language');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_channel, (call) async {
      calls.add(call);
      return call.method == 'initialize' ? true : null;
    });
  });

  Map show() => calls.singleWhere((c) => c.method == 'show').arguments as Map;

  test('data-only job push in the background shows a high-priority job alert', () async {
    await firebaseMessagingBackgroundHandler(jobPush());
    final args = show();
    expect(args['title'], 'New job request');
    expect(args['body'], 'AC Service & Repair • Madhapur, Hyderabad');
    expect(args['payload'], contains('"RequestID":"req-42"'));
    final android = args['platformSpecifics'] as Map;
    expect(android['channelId'], 'job_requests');
    expect(android['sound'], 'notification_sound');
    // Rings until opened, dismissed or taken by another partner; 10 minutes at most.
    expect(android['additionalFlags'], [4]);
    expect(android['timeoutAfter'], inInclusiveRange(5000, kJobRingSeconds * 1000));
    expect(kJobRingSeconds, 600);
    expect(calls.where((c) => c.method == 'createNotificationChannel').map((c) => (c.arguments as Map)['id']),
        containsAll(['high_importance_channel', 'job_requests']));
  });

  test('"job taken" push removes the ringing alert for that job only', () async {
    await firebaseMessagingBackgroundHandler(jobPush());
    final shownId = show()['id'];
    calls.clear();
    await firebaseMessagingBackgroundHandler(const RemoteMessage(
      messageId: 'm2',
      data: {'type': 'JOB_CLOSED', 'RequestID': 'req-42', 'reason': 'ACCEPTED_BY_OTHER'},
    ));
    expect(calls.where((c) => c.method == 'show'), isEmpty);
    final cancel = calls.singleWhere((c) => c.method == 'cancel');
    expect((cancel.arguments as Map)['id'], shownId);
  });

  test('job-closed messages are recognised in the agreed and alias formats', () {
    expect(JobClosed.requestIdOf({'type': 'JOB_CLOSED', 'RequestID': 'r1'}), 'r1');
    expect(JobClosed.requestIdOf({'Type': 'job_taken', 'requestId': 'r2'}), 'r2');
    expect(JobClosed.requestIdOf({'NotificationType': 'JOB_CANCELLED', 'RequestID': 'r3'}), 'r3');
    // A normal new-job push is never treated as closed.
    expect(JobClosed.requestIdOf({'RequestID': 'r4', 'ServiceName': 'AC'}), isNull);
    expect(JobClosed.requestIdOf({'type': 'NEW_JOB', 'RequestID': 'r5'}), isNull);
    expect(JobClosed.requestIdOf({'type': 'JOB_CLOSED'}), isNull);
  });

  test('an open job popup closes and stops ringing when the job is taken', () async {
    final controller = NotificationPopupController();
    controller.open(const PopupConfig(
      requestId: 'req-taken', customerName: 'A', fullAddress: 'B', formattedDate: '', timeSlot: '',
      status: '', mobile: '', paymentStatus: '', services: [], pricing: {},
    ));
    expect(controller.visible, isTrue);
    JobClosed.announce('req-other');
    await Future<void>.delayed(Duration.zero);
    expect(controller.visible, isTrue, reason: 'another job closing must not affect this one');
    JobClosed.announce('req-taken');
    await Future<void>.delayed(Duration.zero);
    expect(controller.visible, isFalse);
    controller.dispose();
  });

  test('alert uses the partner\'s saved language', () async {
    (await SharedPreferences.getInstance()).setString('app_language', 'te');
    await firebaseMessagingBackgroundHandler(jobPush());
    expect(show()['title'], 'కొత్త పని అభ్యర్థన');
  });

  test('pushes the system already shows are not duplicated', () async {
    await firebaseMessagingBackgroundHandler(jobPush(notification: const RemoteNotification(title: 'New job')));
    expect(calls.where((c) => c.method == 'show'), isEmpty);
  });

  test('push token is sent to the server for a signed-in partner, never empty', () async {
    AppSession.userId = 'sample-partner';
    await PushNotificationService.uploadToken('token-abc');
    final req = FakeBackend.requests.singleWhere((r) => r.path.endsWith('updateDeviceToken'));
    expect(req.data, contains('"deviceToken":"token-abc"'));
    expect(req.data, contains('"partnerID":"sample-partner"'));

    FakeBackend.requests.clear();
    await PushNotificationService.uploadToken('');
    AppSession.userId = '';
    await PushNotificationService.uploadToken('token-xyz');
    expect(FakeBackend.requests, isEmpty);
  });

  group('token always reaches the server', () {
    setUp(() {
      PushNotificationService.resetTokenState();
      AppSession.userId = 'p1';
      deviceId = 'tok';
    });

    test('a failed upload is retried until it succeeds, then not sent again', () async {
      var calls = 0;
      Future<bool> send(String id, String token) async {
        calls++;
        if (calls == 1) throw Exception('offline');
        return calls >= 3;
      }

      const gaps = [Duration.zero, Duration.zero, Duration.zero];
      await PushNotificationService.ensureTokenOnServer(retryAfter: gaps, send: send);
      expect(calls, 3);
      await PushNotificationService.ensureTokenOnServer(retryAfter: gaps, send: send);
      expect(calls, 3);
    });

    test('a new login or a new token is sent again', () async {
      final sent = <String>[];
      Future<bool> send(String id, String token) async {
        sent.add('$id|$token');
        return true;
      }

      await PushNotificationService.ensureTokenOnServer(send: send);
      AppSession.userId = 'p2';
      await PushNotificationService.ensureTokenOnServer(send: send);
      deviceId = 'tok2';
      await PushNotificationService.ensureTokenOnServer(send: send);
      expect(sent, ['p1|tok', 'p2|tok', 'p2|tok2']);
    });

    test('nothing is sent before login', () async {
      AppSession.userId = '';
      var calls = 0;
      await PushNotificationService.ensureTokenOnServer(send: (_, _) async {
        calls++;
        return true;
      });
      expect(calls, 0);
    });
  });

  group('job popup ring', () {
    setUp(() => JobRing.enabled = false);

    PopupConfig config() => const PopupConfig(
          requestId: 'r',
          customerName: 'c',
          fullAddress: 'a',
          formattedDate: 'd',
          timeSlot: 't',
          status: 's',
          mobile: 'm',
          paymentStatus: 'p',
          services: [],
          pricing: {},
          apiData: {},
        );

    test('rings until answered, resumes on going back, stops on close', () {
      final c = NotificationPopupController();
      expect(JobRing.isRinging, isFalse);
      c.open(config());
      expect(JobRing.isRinging, isTrue);
      c.goToConfirmAccept();
      expect(JobRing.isRinging, isFalse);
      c.backToJobDetail();
      expect(JobRing.isRinging, isTrue);
      c.close();
      expect(JobRing.isRinging, isFalse);
      c.dispose();
    });

    test('a second job keeps ringing after the first closes', () {
      final a = NotificationPopupController()..open(config());
      final b = NotificationPopupController()..open(config());
      a.close();
      expect(JobRing.isRinging, isTrue);
      b.close();
      expect(JobRing.isRinging, isFalse);
      a.dispose();
      b.dispose();
    });

    test('a push with no popup stops ringing', () async {
      await JobRing.pushArrived();
      expect(JobRing.isRinging, isTrue);
      await JobRing.noPopup();
      expect(JobRing.isRinging, isFalse);
    });
  });
}
