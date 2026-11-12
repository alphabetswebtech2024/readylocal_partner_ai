import 'package:flutter/foundation.dart';
import '../../domain/usecases/save_activation_transaction_usecase.dart';

class ActivationFeeProvider extends ChangeNotifier {
  final SaveActivationTransactionUseCase saveTransactionUseCase;

  ActivationFeeProvider({required this.saveTransactionUseCase});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> saveTransaction({
    required String partnerId,
    required String transactionId,
    required double amount,
    required String moduleId,
    required String moduleName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await saveTransactionUseCase(
        partnerId: partnerId,
        transactionId: transactionId,
        amount: amount,
        moduleId: moduleId,
        moduleName: moduleName,
      );

      final isSuccess = result.when(
        success: (_) {
          _isLoading = false;
          notifyListeners();
          return true;
        },
        failure: (msg) {
          _errorMessage = msg;
          _isLoading = false;
          notifyListeners();
          return false;
        },
      );
      return isSuccess;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
