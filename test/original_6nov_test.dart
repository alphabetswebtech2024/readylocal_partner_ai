import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotask_partner/features/home/data/repositories/home_repository_impl.dart';
import 'package:gotask_partner/features/select_service/data/datasources/select_service_remote_datasource.dart';

/// Behaviour copied from the developer's 6 Nov 2026 code.
void main() {
  test('Learning Services (code LS) is not offered on Select Your Service', () {
    final modules = parseModules({
      'Status': 'SUCCESS',
      'modules': [
        {'_id': 'a', 'Name': 'Home Services', 'Code': 'HS', 'Order': 1, 'isActive': true},
        {'_id': 'b', 'Name': 'Learning Services', 'Code': 'LS', 'Order': 2, 'isActive': true},
        {'_id': 'c', 'Name': 'Nursing', 'Code': 'NURSING', 'Order': 3, 'isActive': true},
        {'_id': 'd', 'Name': 'Old', 'Code': 'OLD', 'Order': 4, 'isActive': false},
      ],
    });
    expect(modules.map((m) => m.moduleCode), ['HS', 'NURSING']);
  });

  test('Home keeps the partner signed in when the server cannot be reached', () {
    final req = RequestOptions(path: '/getPartnerDetails');
    expect(isNetworkFailure(DioException(requestOptions: req, type: DioExceptionType.connectionTimeout)), isTrue);
    expect(isNetworkFailure(DioException(requestOptions: req, type: DioExceptionType.connectionError)), isTrue);
    expect(isNetworkFailure(const SocketException('no route')), isTrue);
    // The server answered (e.g. 401): this still logs out, as in the 6 Nov app.
    expect(
      isNetworkFailure(DioException(
        requestOptions: req,
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: req, statusCode: 401),
      )),
      isFalse,
    );
  });
}
