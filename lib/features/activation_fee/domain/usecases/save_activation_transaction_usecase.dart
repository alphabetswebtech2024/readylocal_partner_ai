import '../../../../core/network/api_result.dart';
import '../repositories/activation_fee_repository.dart';

class SaveActivationTransactionUseCase {
  final ActivationFeeRepository repository;

  SaveActivationTransactionUseCase(this.repository);

  Future<ApiResult<bool>> call({
    required String partnerId,
    required String transactionId,
    required double amount,
    required String moduleId,
    required String moduleName,
  }) {
    return repository.saveTransaction(
      partnerId: partnerId,
      transactionId: transactionId,
      amount: amount,
      moduleId: moduleId,
      moduleName: moduleName,
    );
  }
}
