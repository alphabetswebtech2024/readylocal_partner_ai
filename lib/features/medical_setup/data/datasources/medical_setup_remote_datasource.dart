import 'dart:convert';
import '../../../../core/network/api_constants.dart' as api;
import '../../../../core/network/api_rows.dart';
import '../../../../core/network/catalog_cache.dart';
import '../../../../core/network/api_service.dart';
import '../models/medical_setup_model.dart';

abstract class MedicalSetupRemoteDataSource {
  Future<List<MedicalCategoryModel>> getCategories(String moduleId);
  Future<List<MedicalServiceModel>> getServices(String categoryId, String moduleId);
}

class MedicalSetupRemoteDataSourceImpl implements MedicalSetupRemoteDataSource {
  final ApiService _apiService;

  MedicalSetupRemoteDataSourceImpl(this._apiService);

  @override
  Future<List<MedicalCategoryModel>> getCategories(String moduleId) async {
    final reply = await CatalogCache.post(_apiService, api.getCategories, jsonEncode({'ModuleID': moduleId}));
    return rowsOf(reply, const ['categories']).map(MedicalCategoryModel.fromJson).toList();
  }

  @override
  Future<List<MedicalServiceModel>> getServices(String categoryId, String moduleId) async {
    final reply = await CatalogCache.post(_apiService, api.getServices, jsonEncode({'ModuleID': moduleId, 'CategoryID': categoryId}));
    return groupedRowsOf(reply, const ['data', 'Services', 'services'], 'CategoryID')
        .map(MedicalServiceModel.fromJson)
        .toList();
  }
}
