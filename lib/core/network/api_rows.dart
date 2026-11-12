import 'dart:convert';

import '../localization/server_labels.dart';

/// Helpers for reading the backend's real response formats. Each API names its
/// list differently (`modules`, `categories`, `Services`, `data` ...), and some
/// wrap the JSON as a string inside `body`.

/// Returns the JSON object, opening a string body or a `{statusCode, body}` wrapper.
Map<String, dynamic> openBody(dynamic raw) {
  dynamic body = raw;
  if (body is String) body = _decode(body);
  if (body is Map && body.containsKey('body')) {
    final inner = body['body'];
    body = inner is String ? _decode(inner) : inner;
  }
  return body is Map ? Map<String, dynamic>.from(body) : <String, dynamic>{};
}

dynamic _decode(String text) {
  try {
    return jsonDecode(text);
  } on FormatException {
    return null;
  }
}

/// The rows of the first of [keys] that holds a list.
List<Map<String, dynamic>> rowsOf(dynamic raw, List<String> keys, {bool activeOnly = true}) {
  final body = openBody(raw);
  for (final key in keys) {
    final list = body[key];
    if (list is List) return _rows(list, activeOnly);
  }
  return const [];
}

/// Rows from a `[{CategoryID, services: [...]}]` list, flattened. Each service
/// gets its group's ID under [groupKey], which the setup screens group by.
List<Map<String, dynamic>> groupedRowsOf(dynamic raw, List<String> keys, String groupKey) {
  final out = <Map<String, dynamic>>[];
  for (final group in rowsOf(raw, keys, activeOnly: false)) {
    final services = group['services'];
    if (services is! List) {
      if (group['isActive'] == true) out.add(group);
      continue;
    }
    for (final service in _rows(services, true)) {
      out.add({...service, groupKey: (group[groupKey] ?? '').toString()});
    }
  }
  return out;
}

List<Map<String, dynamic>> _rows(List<dynamic> list, bool activeOnly) => list
    .whereType<Map>()
    .map((row) => Map<String, dynamic>.from(row)..also(learnTeluguName))
    .where((row) => !activeOnly || row['isActive'] == true)
    .toList();

extension _Also on Map<String, dynamic> {
  void also(void Function(Map<String, dynamic>) use) => use(this);
}

/// Reads a number that may arrive as a number or as text.
double numberOf(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim()) ?? 0.0;
  return 0.0;
}
