import 'package:flutter/foundation.dart';
import '../../domain/entities/transaction_detail_entity.dart';
import '../../domain/usecases/get_transaction_details_usecase.dart';

typedef TransactionDetailsController = TransactionDetailsProvider;

class TransactionDetailsProvider extends ChangeNotifier {
  final GetTransactionDetailsUseCase getTransactionDetailsUseCase;

  TransactionDetailsProvider({required this.getTransactionDetailsUseCase});

  bool _isLoading = false;
  String? _errorMessage;
  TransactionDetailEntity? _transaction;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  TransactionDetailEntity? get transaction => _transaction;
  bool get isCompleted => _transaction?.status == 'Completed';

  void setInitialTransaction(TransactionDetailEntity? initial) {
    if (initial != null) {
      _transaction = initial;
      notifyListeners();
    }
  }

  Future<void> loadTransactionDetails(String transactionId) async {
    if (transactionId.isEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getTransactionDetailsUseCase(transactionId);

    result.when(
      success: (detail) {
        _transaction = detail;
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
}
