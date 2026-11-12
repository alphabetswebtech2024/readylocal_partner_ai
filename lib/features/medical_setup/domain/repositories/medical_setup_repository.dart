import '../../../../core/network/api_result.dart';
import '../entities/medical_setup_entity.dart';

abstract class MedicalSetupRepository {
  Future<ApiResult<List<MedicalCategoryEntity>>> getCategories(String moduleId);
  Future<ApiResult<List<MedicalServiceEntity>>> getServices(String categoryId, String moduleId);
}
