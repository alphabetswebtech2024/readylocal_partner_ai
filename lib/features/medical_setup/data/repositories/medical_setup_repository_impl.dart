import '../../../../core/network/api_result.dart';
import '../../domain/entities/medical_setup_entity.dart';
import '../../domain/repositories/medical_setup_repository.dart';
import '../datasources/medical_setup_remote_datasource.dart';

class MedicalSetupRepositoryImpl implements MedicalSetupRepository {
  final MedicalSetupRemoteDataSource remoteDataSource;

  MedicalSetupRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<List<MedicalCategoryEntity>>> getCategories(String moduleId) async {
    try {
      final list = await remoteDataSource.getCategories(moduleId);
      return ApiResult.success(list);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  @override
  Future<ApiResult<List<MedicalServiceEntity>>> getServices(String categoryId, String moduleId) async {
    try {
      final list = await remoteDataSource.getServices(categoryId, moduleId);
      return ApiResult.success(list);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }
}
