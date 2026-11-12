// Withdraw, as in the 6 Nov app: the same request fields, any server answer
// accepted except an explicit refusal (then the server's own reason is shown),
// and Earnings with no data yet shows ₹0 instead of an error.
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotask_partner/core/network/api_client.dart';
import 'package:gotask_partner/core/network/api_service.dart';
import 'package:gotask_partner/features/earnings/data/datasources/earnings_remote_datasource.dart';
import 'package:gotask_partner/features/withdraw/data/datasources/withdraw_remote_datasource.dart';
import 'package:gotask_partner/features/withdraw/data/repositories/withdraw_repository_impl.dart';
import 'package:gotask_partner/features/withdraw/domain/entities/bank_detail_entity.dart';

class _Client implements ApiClient {
  _Client(this.dio);
  @override
  final Dio dio;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ApiService _api(Object reply, List<RequestOptions> seen) {
  final dio = Dio(BaseOptions(baseUrl: 'https://x.test/prod/'))
    ..interceptors.add(InterceptorsWrapper(onRequest: (o, h) {
      seen.add(o);
      h.resolve(Response(requestOptions: o, statusCode: 200, data: reply));
    }));
  return ApiService(_Client(dio));
}

const _bank = BankDetailEntity(
  id: 'b1', bankName: 'SBI', branch: 'Main Branch', accountHolderName: 'Ravi Kumar',
  accountNumber: '1234567890', ifscCode: 'SBIN0001234',
);

void main() {
  test('withdraw sends exactly the 6 Nov fields and succeeds', () async {
    final seen = <RequestOptions>[];
    final repo = WithdrawRepositoryImpl(WithdrawRemoteDataSourceImpl(_api({'Status': 'SUCCESS'}, seen)));
    final result = await repo.requestWithdrawal(partnerId: 'p1', amount: 500, bankDetail: _bank);
    expect(result.when(success: (_) => true, failure: (_) => false), isTrue);
    final body = jsonDecode(seen.single.data as String) as Map;
    expect(body, {
      'partnerId': 'p1',
      'amount': 500.0,
      'paymentMethod': 'BANK',
      'accountDetails': {'accountName': 'Ravi Kumar', 'accountNumber': '1234567890', 'ifsc': 'SBIN0001234'},
      'notes': 'Withdrawal',
    });
  });

  test('a server refusal shows the server\'s own reason', () async {
    final repo = WithdrawRepositoryImpl(WithdrawRemoteDataSourceImpl(
        _api({'Status': 'FAILED', 'Message': 'Minimum withdrawal is ₹100'}, [])));
    final result = await repo.requestWithdrawal(partnerId: 'p1', amount: 50, bankDetail: _bank);
    expect(result.when(success: (_) => '', failure: (m) => m), 'Minimum withdrawal is ₹100');
  });

  test('earnings with no data yet is ₹0, not an error', () async {
    final source = EarningsRemoteDataSourceImpl(_api({'Status': 'SUCCESS'}, []));
    expect(await source.getEarningsSummary('p1'), isEmpty);
  });
}
