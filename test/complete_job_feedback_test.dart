// Work Done feedback must reach the server (approved by the owner 2026-11-05).
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotask_partner/core/network/api_client.dart';
import 'package:gotask_partner/core/network/api_service.dart';
import 'package:gotask_partner/features/job_progress/data/datasources/job_progress_remote_datasource.dart';

class _Client implements ApiClient {
  _Client(this.dio);
  @override
  final Dio dio;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('completedJob sends the partner\'s feedback and the existing fields', () async {
    late Map<String, dynamic> sent;
    final dio = Dio(BaseOptions(baseUrl: 'https://x.test/prod/'))
      ..interceptors.add(InterceptorsWrapper(onRequest: (o, h) {
        sent = jsonDecode(o.data as String) as Map<String, dynamic>;
        h.resolve(Response(requestOptions: o, statusCode: 200, data: {'Status': 'SUCCESS'}));
      }));
    final ok = await JobProgressRemoteDataSourceImpl(ApiService(_Client(dio))).completeJob(
      partnerId: 'p1',
      jobId: 'j1',
      workPicUrls: const ['u/1.jpg'],
      reason: 'Work done',
    );
    expect(ok, isTrue);
    expect(sent, {
      'partnerId': 'p1',
      'jobId': 'j1',
      'JobId': 'j1',
      'WorkPic': ['u/1.jpg'],
      'WorkPics': [
        {'pic': 'u/1.jpg'}
      ],
      'reason': 'Work done',
      'isCustomerAvailable': 'Yes',
    });
  });
}
