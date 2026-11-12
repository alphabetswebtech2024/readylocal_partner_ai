import '../../../../core/network/api_result.dart';
import '../entities/category_entity.dart';

abstract class SelectCategoriesRepository {
  Future<ApiResult<List<CategoryItemEntity>>> getCategories(String moduleId);
  Future<ApiResult<List<SubcategoryItemEntity>>> getSubcategories(String categoryId, String moduleId, {String? moduleName});
  Future<ApiResult<List<ServiceTypeItemEntity>>> getServiceTypes(String moduleId, {String? subCategoryId, String? categoryId});
  Future<ApiResult<List<ServiceItemEntity>>> getServices(String subcategoryId, String moduleId, {String? categoryId, String? moduleName});
  Future<ApiResult<List<dynamic>>> getPersonalCareServices(String moduleId, {List<String>? subCategoryIds});
}
