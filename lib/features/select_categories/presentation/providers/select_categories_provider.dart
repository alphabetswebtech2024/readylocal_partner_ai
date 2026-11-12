import 'package:flutter/foundation.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/usecases/get_categories_usecase.dart';

class SelectCategoriesProvider extends ChangeNotifier {
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetSubcategoriesUseCase getSubcategoriesUseCase;
  final GetServiceTypesUseCase getServiceTypesUseCase;
  final GetServicesUseCase getServicesUseCase;
  final GetPersonalCareServicesUseCase getPersonalCareServicesUseCase;

  SelectCategoriesProvider({
    required this.getCategoriesUseCase,
    required this.getSubcategoriesUseCase,
    required this.getServiceTypesUseCase,
    required this.getServicesUseCase,
    required this.getPersonalCareServicesUseCase,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<CategoryItemEntity> _categories = [];
  List<CategoryItemEntity> get categories => _categories;

  List<SubcategoryItemEntity> _subcategories = [];
  List<SubcategoryItemEntity> get subcategories => _subcategories;

  List<ServiceTypeItemEntity> _serviceTypes = [];
  List<ServiceTypeItemEntity> get serviceTypes => _serviceTypes;

  List<ServiceItemEntity> _services = [];
  List<ServiceItemEntity> get services => _services;

  List<dynamic> _personalCareServices = [];
  List<dynamic> get personalCareServices => _personalCareServices;

  Future<List<CategoryItemEntity>> fetchCategories(String moduleId) async {
    _isLoading = true;
    notifyListeners();
    final result = await getCategoriesUseCase(moduleId);
    _isLoading = false;
    result.when(
      success: (data) => _categories = data,
      failure: (_) => _categories = [],
    );
    notifyListeners();
    return _categories;
  }

  Future<List<SubcategoryItemEntity>> fetchSubcategories(String categoryId, String moduleId, {String? moduleName}) async {
    _isLoading = true;
    notifyListeners();
    final result = await getSubcategoriesUseCase(categoryId, moduleId, moduleName: moduleName);
    _isLoading = false;
    result.when(
      success: (data) => _subcategories = data,
      failure: (_) => _subcategories = [],
    );
    notifyListeners();
    return _subcategories;
  }

  Future<List<SubcategoryItemEntity>> fetchSubCategories({
    required String moduleId,
    String? categoryId,
    String? moduleName,
  }) async {
    return fetchSubcategories(categoryId ?? '', moduleId, moduleName: moduleName);
  }

  Future<List<ServiceTypeItemEntity>> fetchServiceTypes({
    required String moduleId,
    String? subCategoryId,
    String? categoryId,
  }) async {
    _isLoading = true;
    notifyListeners();
    final result = await getServiceTypesUseCase(moduleId, subCategoryId: subCategoryId, categoryId: categoryId);
    _isLoading = false;
    result.when(
      success: (data) => _serviceTypes = data,
      failure: (_) => _serviceTypes = [],
    );
    notifyListeners();
    return _serviceTypes;
  }

  Future<List<ServiceItemEntity>> fetchServices({
    required String moduleId,
    String? categoryId,
    String? subCategoryId,
    String? moduleName,
  }) async {
    _isLoading = true;
    notifyListeners();
    final result = await getServicesUseCase(subCategoryId ?? '', moduleId, categoryId: categoryId, moduleName: moduleName);
    _isLoading = false;
    result.when(
      success: (data) => _services = data,
      failure: (_) => _services = [],
    );
    notifyListeners();
    return _services;
  }

  Future<List<dynamic>> fetchPersonalCareServices({
    required String moduleId,
    List<String>? subCategoryIds,
  }) async {
    _isLoading = true;
    notifyListeners();
    final result = await getPersonalCareServicesUseCase(moduleId, subCategoryIds: subCategoryIds);
    _isLoading = false;
    result.when(
      success: (data) => _personalCareServices = data,
      failure: (_) => _personalCareServices = [],
    );
    notifyListeners();
    return _personalCareServices;
  }
}
