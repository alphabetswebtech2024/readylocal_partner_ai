import 'package:flutter/foundation.dart';
import '../../domain/entities/bank_detail_entity.dart';
import '../../domain/usecases/get_bank_accounts_usecase.dart';
import '../../domain/usecases/request_withdrawal_usecase.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';

typedef WithdrawController = WithdrawProvider;

class WithdrawProvider extends ChangeNotifier {
  final GetBankAccountsUseCase getBankAccountsUseCase;
  final RequestWithdrawalUseCase requestWithdrawalUseCase;

  WithdrawProvider({
    required this.getBankAccountsUseCase,
    required this.requestWithdrawalUseCase,
  });

  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;
  int _selectedBankIndex = 0;
  List<BankDetailEntity> _bankDetails = [];

  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;
  int get selectedBankIndex => _selectedBankIndex;
  List<BankDetailEntity> get bankDetails => _bankDetails;
  BankDetailEntity? get selectedBank =>
      _bankDetails.isNotEmpty && _selectedBankIndex < _bankDetails.length
          ? _bankDetails[_selectedBankIndex]
          : null;

  void selectBank(int index) {
    if (index >= 0 && index < _bankDetails.length) {
      _selectedBankIndex = index;
      notifyListeners();
    }
  }

  Future<void> loadBankDetails(String partnerId) async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getBankAccountsUseCase(partnerId);

    result.when(
      success: (banks) {
        _bankDetails = banks;
        if (_selectedBankIndex >= _bankDetails.length) {
          _selectedBankIndex = 0;
        }
        _isLoading = false;
        notifyListeners();
      },
      failure: (message) {
        _errorMessage = message;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> submitWithdrawal({
    required String partnerId,
    required double amount,
    String notes = 'Withdrawal',
  }) async {
    if (selectedBank == null) {
      _errorMessage = L10n.current.withdrawNoBankSelected;
      notifyListeners();
      return false;
    }

    _isSending = true;
    _errorMessage = null;
    notifyListeners();

    final result = await requestWithdrawalUseCase(
      partnerId: partnerId,
      amount: amount,
      bankDetail: selectedBank!,
      notes: notes,
    );

    bool isSuccess = false;
    result.when(
      success: (_) {
        _isSending = false;
        isSuccess = true;
        notifyListeners();
      },
      failure: (message) {
        _errorMessage = message;
        _isSending = false;
        isSuccess = false;
        notifyListeners();
      },
    );

    return isSuccess;
  }
}
