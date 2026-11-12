import '../../../../core/network/api_result.dart';
import '../../domain/entities/service_module_entity.dart';
import '../../domain/repositories/select_service_repository.dart';
import '../datasources/select_service_remote_datasource.dart';

class SelectServiceRepositoryImpl implements SelectServiceRepository {
  final SelectServiceRemoteDataSource remoteDataSource;

  SelectServiceRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<List<ServiceModuleEntity>>> getModules() async {
    try {
      final list = await remoteDataSource.getModules();
      return ApiResult.success(list);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  @override
  Future<ApiResult<Map<String, double>>> getRegistrationFees(String partnerId) async {
    try {
      final fees = await remoteDataSource.getRegistrationFees(partnerId);
      return ApiResult.success(fees);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }
}
