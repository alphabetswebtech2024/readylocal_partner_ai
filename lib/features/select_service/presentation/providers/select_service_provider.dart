import 'package:flutter/foundation.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../domain/entities/service_module_entity.dart';
import '../../domain/usecases/get_service_modules_usecase.dart';

/// Select Service, as in the 6 Nov app: the services and the registration fees
/// load together, and the screen shows an error with Retry when either fails.
/// No fee is ever guessed when the server's fee list did not arrive.
class SelectServiceProvider extends ChangeNotifier {
  final GetServiceModulesUseCase getModulesUseCase;
  final GetServiceRegistrationFeesUseCase getRegistrationFeesUseCase;

  SelectServiceProvider({
    required this.getModulesUseCase,
    required this.getRegistrationFeesUseCase,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<ServiceModuleEntity> _modules = [];
  List<ServiceModuleEntity> get modules => _modules;

  Map<String, double> _fees = const {};

  /// The server's fee for this service code; 0 means free. ₹500 only when the
  /// server's fee list has no row for this service (same as the 6 Nov app).
  double feeFor(String moduleCode) => _fees[moduleCode.toUpperCase()] ?? 500.0;

  Future<void> loadModules(String partnerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final results = await Future.wait([getModulesUseCase(), getRegistrationFeesUseCase(partnerId)]);
    final modulesResult = results[0] as dynamic;
    final feesResult = results[1] as dynamic;

    _isLoading = false;
    modulesResult.when(
      success: (data) {
        feesResult.when(
          success: (fees) {
            _modules = data as List<ServiceModuleEntity>;
            _fees = fees as Map<String, double>;
          },
          failure: (_) {
            _modules = [];
            _errorMessage = L10n.current.selectServiceFeeFailed;
          },
        );
      },
      failure: (msg) => _errorMessage = msg as String,
    );
    notifyListeners();
  }
}
