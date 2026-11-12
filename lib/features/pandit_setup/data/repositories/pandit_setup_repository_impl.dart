import '../../../../core/network/api_result.dart';
import '../../domain/entities/pandit_setup_entity.dart';
import '../../domain/repositories/pandit_setup_repository.dart';
import '../datasources/pandit_setup_remote_datasource.dart';

class PanditSetupRepositoryImpl implements PanditSetupRepository {
  final PanditSetupRemoteDataSource remoteDataSource;

  PanditSetupRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<List<PanditCategoryEntity>>> getCategories(String moduleId) async {
    try {
      final list = await remoteDataSource.getCategories(moduleId);
      return ApiResult.success(list);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  @override
  Future<ApiResult<List<PanditServiceEntity>>> getServices(String categoryId, String moduleId) async {
    try {
      final list = await remoteDataSource.getServices(categoryId, moduleId);
      return ApiResult.success(list);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }
}
