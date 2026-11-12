import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/driver_setup_entity.dart';
import '../../domain/usecases/get_driver_setup_options_usecase.dart';

class DriverSetupProvider extends ChangeNotifier {
  final GetDriverSetupOptionsUseCase getDriverSetupOptionsUseCase;

  DriverSetupProvider({required this.getDriverSetupOptionsUseCase});

  DriverSetupOptionsEntity _options = const DriverSetupOptionsEntity();
  bool _isLoading = false;
  String? _errorMessage;

  DriverSetupOptionsEntity get options => _options;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<DriverServiceTypeEntity> get serviceTypes => _options.serviceTypes;
  List<DriverLicenseTypeEntity> get licenseTypes => _options.licenseTypes;
  List<VehicleTypeEntity> get vehicleTypes => _options.vehicleTypes;
  List<SafetySkillEntity> get safetySkills => _options.safetySkills;

  Future<void> fetchOptions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getDriverSetupOptionsUseCase();
    result.when(
      success: (data) => _options = data,
      failure: (message) => _errorMessage = message,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> saveDriverProfile(Map<String, dynamic> payload) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'professionalProfile',
        jsonEncode(payload['professionalProfile']),
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
