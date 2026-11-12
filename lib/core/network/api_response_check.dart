import 'package:dio/dio.dart';

/// The backend often answers HTTP 200 with `{"Status":"FAILED","StatusCode":400,...}`
/// when a request is rejected. Checking only the HTTP code made the app treat
/// those as success (for example showing a job as accepted when it was not).
/// A call counts as failed when the body says so; a body with no status keeps
/// the old meaning (any 2xx is success).
bool apiCallSucceeded(Response<dynamic> response) {
  final code = response.statusCode;
  if (code == null || code < 200 || code >= 300) return false;
  final body = response.data;
  if (body is! Map) return true;
  final status = body['Status'] ?? body['status'];
  if (status is String && status.toUpperCase() == 'FAILED') return false;
  final inner = body['StatusCode'] ?? body['statusCode'];
  if (inner is num && inner >= 400) return false;
  return true;
}
