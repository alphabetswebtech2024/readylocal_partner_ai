import 'earnings_summary_entity.dart';
import 'transaction_entity.dart';

class EarningsDetailsEntity {
  final EarningsSummaryEntity summary;
  final List<TransactionEntity> transactions;

  const EarningsDetailsEntity({
    this.summary = const EarningsSummaryEntity(),
    this.transactions = const [],
  });

  List<TransactionEntity> get completedTransactions =>
      transactions.where((t) => t.status == 'Completed').toList();

  List<TransactionEntity> get pendingTransactions =>
      transactions.where((t) => t.status == 'Pending').toList();
}
