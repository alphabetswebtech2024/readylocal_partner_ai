import 'package:flutter/foundation.dart';
import '../../domain/entities/earnings_summary_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/usecases/get_earnings_usecase.dart';

typedef EarningsController = EarningsProvider;

class EarningsProvider extends ChangeNotifier {
  final GetEarningsUseCase getEarningsUseCase;

  EarningsProvider({required this.getEarningsUseCase});

  bool _isLoading = false;
  String? _errorMessage;
  String _selectedPeriod = 'Daily'; // 'Daily' | 'Weekly' | 'Monthly'
  String _selectedTab = 'Pending'; // 'Completed' | 'Pending'

  EarningsSummaryEntity _summary = const EarningsSummaryEntity();
  List<TransactionEntity> _completedTransactions = [];
  List<TransactionEntity> _pendingTransactions = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedPeriod => _selectedPeriod;
  String get selectedTab => _selectedTab;
  EarningsSummaryEntity get summary => _summary;
  List<TransactionEntity> get completedTransactions => _completedTransactions;
  List<TransactionEntity> get pendingTransactions => _pendingTransactions;

  void setPeriod(String period) {
    if (_selectedPeriod != period) {
      _selectedPeriod = period;
      notifyListeners();
    }
  }

  void setTab(String tab) {
    if (_selectedTab != tab) {
      _selectedTab = tab;
      notifyListeners();
    }
  }

  Future<void> loadEarnings(String partnerId) async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getEarningsUseCase(partnerId);

    result.when(
      success: (details) {
        _summary = details.summary;
        _completedTransactions = details.completedTransactions;
        _pendingTransactions = details.pendingTransactions;
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
