// Fees use the server's real format: one row per service code. 0 means waived.
// As in the 6 Nov app: a service with no row is ₹500, but a failed fee request
// stops Select Service with an error and Retry; it never charges ₹500.
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotask_partner/core/network/api_client.dart';
import 'package:gotask_partner/core/network/api_result.dart';
import 'package:gotask_partner/core/network/api_service.dart';
import 'package:gotask_partner/features/select_service/data/datasources/select_service_remote_datasource.dart';
import 'package:gotask_partner/features/select_service/domain/entities/service_module_entity.dart';
import 'package:gotask_partner/features/select_service/domain/repositories/select_service_repository.dart';
import 'package:gotask_partner/features/select_service/domain/usecases/get_service_modules_usecase.dart';
import 'package:gotask_partner/features/select_service/presentation/providers/select_service_provider.dart';

class _Client implements ApiClient {
  _Client(this.dio);
  @override
  final Dio dio;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Repo implements SelectServiceRepository {
  _Repo(this.fees);
  final ApiResult<Map<String, double>> fees;
  @override
  Future<ApiResult<List<ServiceModuleEntity>>> getModules() async => const ApiResult.success([]);
  @override
  Future<ApiResult<Map<String, double>>> getRegistrationFees(String partnerId) async => fees;
}

const _live = {
  'Status': 'SUCCESS',
  'RegistrationFees': [
    {'level': 'Module', 'refId': 'HS', 'amount': 0, 'isActive': true},
    {'level': 'Module', 'refId': 'purohit', 'amount': 750, 'isActive': true},
    {'level': 'Module', 'refId': 'BAD', 'amount': 'x', 'isActive': true},
  ],
};

void main() {
  test('fee request is a plain GET, as in the 6 Nov app', () async {
    late RequestOptions seen;
    final dio = Dio(BaseOptions(baseUrl: 'https://x.test/prod/'))
      ..interceptors.add(InterceptorsWrapper(onRequest: (o, h) {
        seen = o;
        h.resolve(Response(requestOptions: o, statusCode: 200, data: _live));
      }));
    final source = SelectServiceRemoteDataSourceImpl(ApiService(_Client(dio)));
    expect(await source.getRegistrationFees('p1'), {'HS': 0.0, 'PUROHIT': 750.0});
    expect(seen.method, 'GET');
    expect(seen.queryParameters, isEmpty);
  });

  test('a failed or unexpected response is a failure, not an empty fee list', () {
    expect(() => parseRegistrationFees({'Status': 'FAILED', 'RegistrationFees': []}), throwsException);
    expect(() => parseRegistrationFees('not json'), throwsException);
    expect(() => parseRegistrationFees(null), throwsException);
  });

  SelectServiceProvider provider(ApiResult<Map<String, double>> fees) {
    final repo = _Repo(fees);
    return SelectServiceProvider(
      getModulesUseCase: GetServiceModulesUseCase(repo),
      getRegistrationFeesUseCase: GetServiceRegistrationFeesUseCase(repo),
    );
  }

  test('fee per service: 0 stays 0, a service with no row is ₹500', () async {
    final p = provider(ApiResult.success(parseRegistrationFees(_live)));
    await p.loadModules('p1');
    expect(p.errorMessage, isNull);
    expect(p.feeFor('HS'), 0);
    expect(p.feeFor('PUROHIT'), 750);
    expect(p.feeFor('NEW_SERVICE'), 500);
  });

  test('fee request failing shows the error with Retry; no service can be chosen', () async {
    final p = provider(const ApiResult.failure('offline'));
    await p.loadModules('p1');
    expect(p.errorMessage, 'Could not load the registration fee. Please check your internet and try again.');
    expect(p.modules, isEmpty);
  });
}
