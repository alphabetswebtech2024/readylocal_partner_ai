import '../../../../core/network/api_result.dart';
import '../entities/transaction_detail_entity.dart';

abstract class TransactionDetailsRepository {
  Future<ApiResult<TransactionDetailEntity>> getTransactionDetails(String transactionId);
}
