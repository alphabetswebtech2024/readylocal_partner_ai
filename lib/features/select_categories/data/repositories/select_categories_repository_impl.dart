import '../../../../core/network/api_result.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/select_categories_repository.dart';
import '../datasources/select_categories_remote_datasource.dart';

class SelectCategoriesRepositoryImpl implements SelectCategoriesRepository {
  final SelectCategoriesRemoteDataSource remoteDataSource;

  SelectCategoriesRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<List<CategoryItemEntity>>> getCategories(String moduleId) async {
    try {
      final list = await remoteDataSource.getCategories(moduleId);
      return ApiResult.success(list);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  @override
  Future<ApiResult<List<SubcategoryItemEntity>>> getSubcategories(String categoryId, String moduleId, {String? moduleName}) async {
    try {
      final list = await remoteDataSource.getSubcategories(categoryId, moduleId, moduleName: moduleName);
      return ApiResult.success(list);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  @override
  Future<ApiResult<List<ServiceTypeItemEntity>>> getServiceTypes(String moduleId, {String? subCategoryId, String? categoryId}) async {
    try {
      final list = await remoteDataSource.getServiceTypes(moduleId, subCategoryId: subCategoryId, categoryId: categoryId);
      return ApiResult.success(list);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  @override
  Future<ApiResult<List<ServiceItemEntity>>> getServices(String subcategoryId, String moduleId, {String? categoryId, String? moduleName}) async {
    try {
      final list = await remoteDataSource.getServices(subcategoryId, moduleId, categoryId: categoryId, moduleName: moduleName);
      return ApiResult.success(list);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  @override
  Future<ApiResult<List<dynamic>>> getPersonalCareServices(String moduleId, {List<String>? subCategoryIds}) async {
    try {
      final list = await remoteDataSource.getPersonalCareServices(moduleId, subCategoryIds: subCategoryIds);
      return ApiResult.success(list);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }
}
