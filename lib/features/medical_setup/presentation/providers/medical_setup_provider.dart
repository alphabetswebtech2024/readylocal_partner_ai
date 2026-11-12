import 'package:flutter/foundation.dart';
import '../../domain/entities/medical_setup_entity.dart';
import '../../domain/usecases/get_medical_services_usecase.dart';

class MedicalSetupProvider extends ChangeNotifier {
  final GetMedicalCategoriesUseCase getCategoriesUseCase;
  final GetMedicalServicesUseCase getServicesUseCase;

  MedicalSetupProvider({
    required this.getCategoriesUseCase,
    required this.getServicesUseCase,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<MedicalCategoryEntity> _categories = [];
  List<MedicalCategoryEntity> get categories => _categories;

  List<MedicalServiceEntity> _services = [];
  List<MedicalServiceEntity> get services => _services;

  Future<List<MedicalCategoryEntity>> fetchCategories(String moduleId) async {
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

  Future<List<MedicalServiceEntity>> fetchServices({
    required String moduleId,
    required String categoryId,
  }) async {
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
}
