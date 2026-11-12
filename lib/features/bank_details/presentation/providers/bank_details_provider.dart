import 'package:flutter/foundation.dart';
import '../../domain/usecases/add_bank_account_usecase.dart';

class BankDetailsProvider extends ChangeNotifier {
  final AddBankAccountUseCase addBankAccountUseCase;

  BankDetailsProvider({required this.addBankAccountUseCase});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> addAccount({
    required String partnerId,
    required String accountName,
    required String accountNumber,
    required String ifsc,
    required String bankName,
  }) =>
      submitBankDetails(
        partnerId: partnerId,
        accountName: accountName,
        accountNumber: accountNumber,
        ifsc: ifsc,
        bankName: bankName,
      );

  Future<bool> submitBankDetails({
    required String partnerId,
    required String accountName,
    required String accountNumber,
    required String ifsc,
    required String bankName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await addBankAccountUseCase(
        partnerId: partnerId,
        accountName: accountName,
        accountNumber: accountNumber,
        ifsc: ifsc,
        bankName: bankName,
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
