import '../../../../core/network/api_result.dart';
import '../entities/transaction_detail_entity.dart';
import '../repositories/transaction_details_repository.dart';

class GetTransactionDetailsUseCase {
  final TransactionDetailsRepository repository;

  GetTransactionDetailsUseCase(this.repository);

  Future<ApiResult<TransactionDetailEntity>> call(String transactionId) {
    return repository.getTransactionDetails(transactionId);
  }
}
