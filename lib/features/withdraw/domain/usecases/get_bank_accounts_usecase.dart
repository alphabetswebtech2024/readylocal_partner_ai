import '../../../../core/network/api_result.dart';
import '../entities/bank_detail_entity.dart';
import '../repositories/withdraw_repository.dart';

class GetBankAccountsUseCase {
  final WithdrawRepository repository;

  GetBankAccountsUseCase(this.repository);

  Future<ApiResult<List<BankDetailEntity>>> call(String partnerId) {
    return repository.getBankAccounts(partnerId);
  }
}
