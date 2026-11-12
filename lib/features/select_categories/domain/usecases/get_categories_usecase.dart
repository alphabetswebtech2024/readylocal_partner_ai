import '../../../../core/network/api_result.dart';
import '../entities/category_entity.dart';
import '../repositories/select_categories_repository.dart';

class GetCategoriesUseCase {
  final SelectCategoriesRepository repository;

  GetCategoriesUseCase(this.repository);

  Future<ApiResult<List<CategoryItemEntity>>> call(String moduleId) {
    return repository.getCategories(moduleId);
  }
}

class GetSubcategoriesUseCase {
  final SelectCategoriesRepository repository;

  GetSubcategoriesUseCase(this.repository);

  Future<ApiResult<List<SubcategoryItemEntity>>> call(String categoryId, String moduleId, {String? moduleName}) {
    return repository.getSubcategories(categoryId, moduleId, moduleName: moduleName);
  }
}

class GetServiceTypesUseCase {
  final SelectCategoriesRepository repository;

  GetServiceTypesUseCase(this.repository);

  Future<ApiResult<List<ServiceTypeItemEntity>>> call(String moduleId, {String? subCategoryId, String? categoryId}) {
    return repository.getServiceTypes(moduleId, subCategoryId: subCategoryId, categoryId: categoryId);
  }
}

class GetServicesUseCase {
  final SelectCategoriesRepository repository;

  GetServicesUseCase(this.repository);

  Future<ApiResult<List<ServiceItemEntity>>> call(String subcategoryId, String moduleId, {String? categoryId, String? moduleName}) {
    return repository.getServices(subcategoryId, moduleId, categoryId: categoryId, moduleName: moduleName);
  }
}

class GetPersonalCareServicesUseCase {
  final SelectCategoriesRepository repository;

  GetPersonalCareServicesUseCase(this.repository);

  Future<ApiResult<List<dynamic>>> call(String moduleId, {List<String>? subCategoryIds}) {
    return repository.getPersonalCareServices(moduleId, subCategoryIds: subCategoryIds);
  }
}
