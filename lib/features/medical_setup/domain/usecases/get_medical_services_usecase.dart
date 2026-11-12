import '../../../../core/network/api_result.dart';
import '../entities/medical_setup_entity.dart';
import '../repositories/medical_setup_repository.dart';

class GetMedicalCategoriesUseCase {
  final MedicalSetupRepository repository;

  GetMedicalCategoriesUseCase(this.repository);

  Future<ApiResult<List<MedicalCategoryEntity>>> call(String moduleId) {
    return repository.getCategories(moduleId);
  }
}

class GetMedicalServicesUseCase {
  final MedicalSetupRepository repository;

  GetMedicalServicesUseCase(this.repository);

  Future<ApiResult<List<MedicalServiceEntity>>> call(String categoryId, String moduleId) {
    return repository.getServices(categoryId, moduleId);
  }
}
