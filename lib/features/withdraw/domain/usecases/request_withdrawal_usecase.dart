import '../../../../core/network/api_result.dart';
import '../entities/bank_detail_entity.dart';
import '../repositories/withdraw_repository.dart';

class RequestWithdrawalUseCase {
  final WithdrawRepository repository;

  RequestWithdrawalUseCase(this.repository);

  Future<ApiResult<bool>> call({
    required String partnerId,
    required double amount,
    required BankDetailEntity bankDetail,
    String notes = 'Withdrawal',
  }) {
    return repository.requestWithdrawal(
      partnerId: partnerId,
      amount: amount,
      bankDetail: bankDetail,
      notes: notes,
    );
  }
}
