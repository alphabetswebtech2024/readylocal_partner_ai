import 'dart:async';

/// How long a job request keeps ringing and can be answered, at most. The ring
/// stops earlier when the partner answers or the server says another partner
/// accepted it (like delivery apps: it rings until someone takes the job).
/// The 6 Nov app used 45 seconds; changed on the owner's request 2026-11-08.
const int kJobRequestWindowSeconds = 600;

/// "This job is no longer open" messages from the server: another partner
/// accepted it, or the customer cancelled. The job keeps ringing on every
/// partner's phone until one of these arrives (or the partner answers).
///
/// Server contract (data-only FCM push to the other partners):
///   {"type": "JOB_CLOSED", "RequestID": "<request id>", "reason": "ACCEPTED_BY_OTHER" | "CANCELLED"}
/// The aliases below are accepted too, so small naming differences still work.
class JobClosed {
  JobClosed._();

  static const Set<String> _closeTypes = {
    'JOB_CLOSED',
    'JOB_TAKEN',
    'JOB_ACCEPTED_BY_OTHER',
    'ACCEPTED_BY_OTHER',
    'JOB_ACCEPTED',
    'JOB_CANCELLED',
    'REQUEST_CANCELLED',
    'JOB_EXPIRED',
  };

  static final StreamController<String> _events = StreamController<String>.broadcast();
  static final Map<String, DateTime> _closed = {};

  /// Request ids as they close, for open popups and job screens.
  static Stream<String> get stream => _events.stream;

  /// The request id if [data] is a "job closed" push, otherwise null.
  static String? requestIdOf(Map<String, dynamic>? data) {
    if (data == null) return null;
    String field(List<String> keys) {
      for (final k in keys) {
        final v = data[k];
        if (v != null && v.toString().trim().isNotEmpty) return v.toString().trim();
      }
      return '';
    }

    final type = field(const ['type', 'Type', 'NotificationType', 'notificationType', 'event', 'Event']).toUpperCase();
    if (!_closeTypes.contains(type)) return null;
    final id = field(const ['RequestID', 'requestId', 'RequestId', 'requestID']);
    return id.isEmpty ? null : id;
  }

  /// The same id the job alert notification was shown with, so it can be removed.
  static int notificationIdFor(String requestId) => requestId.hashCode & 0x7fffffff;

  static void announce(String requestId) {
    final now = DateTime.now();
    _closed.removeWhere((_, at) => now.difference(at) > const Duration(minutes: 30));
    _closed[requestId] = now;
    _events.add(requestId);
  }

  static bool isClosed(String? requestId) => requestId != null && _closed.containsKey(requestId);
}
