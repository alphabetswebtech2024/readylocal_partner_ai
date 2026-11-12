import 'dart:convert';
import '../../../../core/network/api_constants.dart' as api;
import '../../../../core/network/api_rows.dart';
import '../../../../core/network/catalog_cache.dart';
import '../../../../core/network/api_service.dart';
import '../models/category_model.dart';

abstract class SelectCategoriesRemoteDataSource {
  Future<List<CategoryItemModel>> getCategories(String moduleId);
  Future<List<SubcategoryItemModel>> getSubcategories(String categoryId, String moduleId, {String? moduleName});
  Future<List<ServiceTypeItemModel>> getServiceTypes(String moduleId, {String? subCategoryId, String? categoryId});
  Future<List<ServiceItemModel>> getServices(String subcategoryId, String moduleId, {String? categoryId, String? moduleName});
  Future<List<dynamic>> getPersonalCareServices(String moduleId, {List<String>? subCategoryIds});
}

class SelectCategoriesRemoteDataSourceImpl implements SelectCategoriesRemoteDataSource {
  final ApiService _apiService;

  SelectCategoriesRemoteDataSourceImpl(this._apiService);

  @override
  Future<List<CategoryItemModel>> getCategories(String moduleId) async {
    final reply = await CatalogCache.post(_apiService, api.getCategories, jsonEncode({'ModuleID': moduleId}));
    return rowsOf(reply, const ['categories']).map(CategoryItemModel.fromJson).toList();
  }

  @override
  Future<List<SubcategoryItemModel>> getSubcategories(String categoryId, String moduleId, {String? moduleName}) async {
    final reply = await CatalogCache.post(_apiService, api.getSubCategories, jsonEncode({
        'ModuleID': moduleId,
        'ModuleName': moduleName ?? '',
        'isActive': true,
        if (categoryId.isNotEmpty) 'CategoryID': categoryId,
      }));
    return rowsOf(reply, const ['subCategories']).map(SubcategoryItemModel.fromJson).toList();
  }

  @override
  Future<List<ServiceTypeItemModel>> getServiceTypes(String moduleId, {String? subCategoryId, String? categoryId}) async {
    final reply = await CatalogCache.post(_apiService, api.getServiceType, jsonEncode({
        'ModuleID': moduleId,
        'SubCategoryID': subCategoryId,
        'isActive': true,
        'CategoryID': ?categoryId,
      }));
    return rowsOf(reply, const ['ServiceTypes']).map(ServiceTypeItemModel.fromJson).toList();
  }

  @override
  Future<List<ServiceItemModel>> getServices(String subcategoryId, String moduleId, {String? categoryId, String? moduleName}) async {
    final reply = await CatalogCache.post(_apiService, api.getServices, jsonEncode({
        'ModuleID': moduleId,
        'ModuleName': moduleName ?? '',
        'SubCategoryID': subcategoryId,
        'ServiceTypeID': '',
        'ServiceVariantID': '',
        'isActive': true,
        'HubID': '69ce6cb853d0272907678254',
        'AreaID': '69cf47f382f21472bfa83ae4',
        'CategoryID': ?categoryId,
      }));
    return rowsOf(reply, const ['Services', 'services', 'data']).map(ServiceItemModel.fromJson).toList();
  }

  @override
  Future<List<dynamic>> getPersonalCareServices(String moduleId, {List<String>? subCategoryIds}) async {
    final reply = await CatalogCache.post(_apiService, api.getPersonalCareServices, jsonEncode({
        'ModuleID': moduleId,
        'SubCategoryID': (subCategoryIds ?? const <String>[]).join(','),
      }));
    return groupedRowsOf(reply, const ['data'], 'SubCategoryID');
  }
}
