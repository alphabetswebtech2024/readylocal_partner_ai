import '../../../../core/network/api_result.dart';
import '../../domain/repositories/bank_details_repository.dart';
import '../datasources/bank_details_remote_datasource.dart';

class BankDetailsRepositoryImpl implements BankDetailsRepository {
  final BankDetailsRemoteDataSource remoteDataSource;

  BankDetailsRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<bool>> addBankAccount({
    required String partnerId,
    required String accountName,
    required String accountNumber,
    required String ifsc,
    required String bankName,
  }) async {
    try {
      final success = await remoteDataSource.addBankAccount(
        partnerId: partnerId,
        accountName: accountName,
        accountNumber: accountNumber,
        ifsc: ifsc,
        bankName: bankName,
      );
      if (success) {
        return const ApiResult.success(true);
      }
      return const ApiResult.failure('Failed to add bank account');
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }
}
