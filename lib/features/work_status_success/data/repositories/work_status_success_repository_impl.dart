import '../../../../core/network/api_result.dart';
import '../../domain/entities/work_status_success_entity.dart';
import '../../domain/repositories/work_status_success_repository.dart';
import '../datasources/work_status_success_local_datasource.dart';

class WorkStatusSuccessRepositoryImpl implements WorkStatusSuccessRepository {
  final WorkStatusSuccessLocalDataSource localDataSource;

  WorkStatusSuccessRepositoryImpl(this.localDataSource);

  @override
  Future<ApiResult<WorkStatusSuccessEntity>> getSuccessDetails(String partnerName) async {
    try {
      final result = localDataSource.getSuccessDetails(partnerName);
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }
}
