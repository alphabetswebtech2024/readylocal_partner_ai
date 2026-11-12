import '../../../../core/network/api_result.dart';
import '../entities/pandit_setup_entity.dart';
import '../repositories/pandit_setup_repository.dart';

class GetPanditCategoriesUseCase {
  final PanditSetupRepository repository;

  GetPanditCategoriesUseCase(this.repository);

  Future<ApiResult<List<PanditCategoryEntity>>> call(String moduleId) {
    return repository.getCategories(moduleId);
  }
}

class GetPanditServicesUseCase {
  final PanditSetupRepository repository;

  GetPanditServicesUseCase(this.repository);

  Future<ApiResult<List<PanditServiceEntity>>> call(String categoryId, String moduleId) {
    return repository.getServices(categoryId, moduleId);
  }
}
