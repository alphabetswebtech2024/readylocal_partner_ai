// API behaviour found by testing the live server (2026-11-05). No real network.
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotask_partner/core/network/api_client.dart';
import 'package:gotask_partner/core/network/api_response_check.dart';
import 'package:gotask_partner/core/services/image_upload_service.dart';

Response<dynamic> _res(int code, dynamic body) =>
    Response(requestOptions: RequestOptions(path: '/x'), statusCode: code, data: body);

class _Adapter implements HttpClientAdapter {
  _Adapter(this.script);
  final List<int> script; // status per attempt; 0 = network failure
  int calls = 0;
  @override
  void close({bool force = false}) {}
  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<List<int>>? s, Future<void>? c) async {
    final code = script[calls.clamp(0, script.length - 1)];
    calls++;
    if (code == 0) {
      throw DioException.connectionError(requestOptions: o, reason: 'down');
    }
    return ResponseBody.fromString(jsonEncode({'Status': 'SUCCESS'}), code,
        headers: {'content-type': ['application/json']});
  }
}

Dio _dio(_Adapter a) {
  final d = Dio(BaseOptions(baseUrl: 'https://x.test/prod/'))..httpClientAdapter = a;
  d.interceptors.add(RetryReadsInterceptor(d, baseDelay: Duration.zero));
  return d;
}

void main() {
  group('apiCallSucceeded', () {
    test('HTTP 200 with Status FAILED is a failure (live acceptedJob response)', () {
      expect(apiCallSucceeded(_res(200, {'Status': 'FAILED', 'StatusCode': 400, 'Message': 'x'})), isFalse);
    });
    test('real successes still succeed', () {
      expect(apiCallSucceeded(_res(200, {'Status': 'SUCCESS', 'StatusCode': 200})), isTrue);
      expect(apiCallSucceeded(_res(200, {'message': 'ok'})), isTrue);
      expect(apiCallSucceeded(_res(201, 'done')), isTrue);
    });
    test('HTTP errors fail', () => expect(apiCallSucceeded(_res(500, {})), isFalse));
  });

  group('uploadedPath reads both response shapes', () {
    test('filePath, location, nested', () {
      expect(ImageUploadService.uploadedPath({'Status': 'SUCCESS', 'filePath': 'a'}), 'a');
      expect(ImageUploadService.uploadedPath({'location': 'b'}), 'b');
      expect(ImageUploadService.uploadedPath({'Data': {'url': 'c'}}), 'c');
    });
    test('failure or nothing returns null', () {
      expect(ImageUploadService.uploadedPath({'Status': 'FAILED', 'filePath': 'a'}), isNull);
      expect(ImageUploadService.uploadedPath('x'), isNull);
    });
  });

  group('network retry', () {
    test('a read API is retried after a dropped connection', () async {
      final a = _Adapter([0, 200]);
      final r = await _dio(a).post('getPartnerDetails', data: '{}');
      expect(r.statusCode, 200);
      expect(a.calls, 2);
    });

    test('a read API gives up after two retries', () async {
      final a = _Adapter([0]);
      await expectLater(_dio(a).post('getModules', data: '{}'), throwsA(isA<DioException>()));
      expect(a.calls, 3);
    });

    for (final write in const [
      'acceptedJob', 'rejectedJob', 'completedJob', 'cancelledJob', 'withdrawRequest', 'saveTransaction_pat',
      'partnerOTP', 'partnerValidateOTP', 'addBankAccount', 'updateProfile_pat', 'uploadToS3', 'partnerOnOrOff',
      'startLocation_pat', 'reachedLocation_pat',
    ]) {
      test('$write is never repeated automatically', () async {
        final a = _Adapter([0]);
        await expectLater(_dio(a).post(write, data: '{}'), throwsA(isA<DioException>()));
        expect(a.calls, 1);
      });
    }
  });
}
