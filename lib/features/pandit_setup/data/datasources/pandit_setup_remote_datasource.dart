import 'dart:convert';
import '../../../../core/network/api_constants.dart' as api;
import '../../../../core/network/api_rows.dart';
import '../../../../core/network/catalog_cache.dart';
import '../../../../core/network/api_service.dart';
import '../models/pandit_setup_model.dart';

abstract class PanditSetupRemoteDataSource {
  Future<List<PanditCategoryModel>> getCategories(String moduleId);
  Future<List<PanditServiceModel>> getServices(String categoryId, String moduleId);
}

class PanditSetupRemoteDataSourceImpl implements PanditSetupRemoteDataSource {
  final ApiService _apiService;

  PanditSetupRemoteDataSourceImpl(this._apiService);

  @override
  Future<List<PanditCategoryModel>> getCategories(String moduleId) async {
    final reply = await CatalogCache.post(_apiService, api.getCategories, jsonEncode({'ModuleID': moduleId}));
    return rowsOf(reply, const ['categories']).map(PanditCategoryModel.fromJson).toList();
  }

  @override
  Future<List<PanditServiceModel>> getServices(String categoryId, String moduleId) async {
    final reply = await CatalogCache.post(_apiService, api.getPurohitServices, jsonEncode({'ModuleID': moduleId, 'CategoryID': categoryId}));
    return groupedRowsOf(reply, const ['data'], 'CategoryID').map(PanditServiceModel.fromJson).toList();
  }
}
