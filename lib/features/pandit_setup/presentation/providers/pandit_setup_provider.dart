import 'package:flutter/foundation.dart';
import '../../domain/entities/pandit_setup_entity.dart';
import '../../domain/usecases/get_pandit_services_usecase.dart';

class PanditSetupProvider extends ChangeNotifier {
  final GetPanditCategoriesUseCase getCategoriesUseCase;
  final GetPanditServicesUseCase getServicesUseCase;

  PanditSetupProvider({
    required this.getCategoriesUseCase,
    required this.getServicesUseCase,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<PanditCategoryEntity> _categories = [];
  List<PanditCategoryEntity> get categories => _categories;

  List<PanditServiceEntity> _services = [];
  List<PanditServiceEntity> get services => _services;

  Future<List<PanditCategoryEntity>> fetchCategories(String moduleId) async {
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

  Future<List<PanditServiceEntity>> fetchServices(String categoryId, String moduleId) async {
    _isLoading = true;
    notifyListeners();

    final result = await getServicesUseCase(categoryId, moduleId);
    _isLoading = false;

    result.when(
      success: (data) => _services = data,
      failure: (_) => _services = [],
    );

    notifyListeners();
    return _services;
  }

  Future<List<PanditServiceEntity>> fetchPurohitServices({
    required String moduleId,
    required List<String> categoryIds,
  }) async {
    return fetchServices(categoryIds.join(','), moduleId);
  }
}
