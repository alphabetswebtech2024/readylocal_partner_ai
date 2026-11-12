import 'api_service.dart';

/// Service lists change rarely, and each setup sheet asked for them again every
/// time it opened. Answers are kept for a few minutes, so a sheet opens at once.
/// Only these read-only lists use it; fees, payments and jobs are always fresh.
class CatalogCache {
  CatalogCache._();

  static const _keepFor = Duration(minutes: 10);
  static final Map<String, ({DateTime at, Future<dynamic> reply})> _kept = {};

  static void clear() => _kept.clear();

  static Future<dynamic> _load(String key, Future<dynamic> Function() ask) {
    final kept = _kept[key];
    if (kept != null && DateTime.now().difference(kept.at) < _keepFor) return kept.reply;
    final reply = ask();
    _kept[key] = (at: DateTime.now(), reply: reply);
    // A failed request or a failure reply is never kept.
    reply.then<void>((body) {
      if (body is! Map || body['Status'] != 'SUCCESS') _kept.remove(key);
    }, onError: (Object _) {
      _kept.remove(key);
    });
    return reply;
  }

  static Future<dynamic> post(ApiService api, String url, String body) =>
      _load('$url|$body', () async => (await api.post(url, data: body)).data);

  static Future<dynamic> get(ApiService api, String url) =>
      _load(url, () async => (await api.get(url)).data);
}
