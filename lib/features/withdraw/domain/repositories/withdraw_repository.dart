import '../../../../core/network/api_result.dart';
import '../entities/bank_detail_entity.dart';

abstract class WithdrawRepository {
  Future<ApiResult<List<BankDetailEntity>>> getBankAccounts(String partnerId);
  Future<ApiResult<bool>> requestWithdrawal({
    required String partnerId,
    required double amount,
    required BankDetailEntity bankDetail,
    String notes = 'Withdrawal',
  });
}
