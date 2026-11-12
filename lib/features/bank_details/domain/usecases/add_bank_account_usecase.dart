import '../../../../core/network/api_result.dart';
import '../repositories/bank_details_repository.dart';

class AddBankAccountUseCase {
  final BankDetailsRepository repository;

  AddBankAccountUseCase(this.repository);

  Future<ApiResult<bool>> call({
    required String partnerId,
    required String accountName,
    required String accountNumber,
    required String ifsc,
    required String bankName,
  }) {
    return repository.addBankAccount(
      partnerId: partnerId,
      accountName: accountName,
      accountNumber: accountNumber,
      ifsc: ifsc,
      bankName: bankName,
    );
  }
}
