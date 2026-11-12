import '../../../../core/network/api_result.dart';

abstract class BankDetailsRepository {
  Future<ApiResult<bool>> addBankAccount({
    required String partnerId,
    required String accountName,
    required String accountNumber,
    required String ifsc,
    required String bankName,
  });
}
