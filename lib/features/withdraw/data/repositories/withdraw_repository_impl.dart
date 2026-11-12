import 'dart:developer';
import '../../../../core/network/api_result.dart';
import '../../domain/entities/bank_detail_entity.dart';
import '../../domain/repositories/withdraw_repository.dart';
import '../datasources/withdraw_remote_datasource.dart';

class WithdrawRepositoryImpl implements WithdrawRepository {
  final WithdrawRemoteDataSource remoteDataSource;

  WithdrawRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<List<BankDetailEntity>>> getBankAccounts(String partnerId) async {
    try {
      final accounts = await remoteDataSource.getBankAccounts(partnerId);
      return ApiResult.success(accounts);
    } catch (e) {
      log('Error fetching bank accounts: $e');
      return ApiResult.failure(e is Exception ? e.toString() : 'Unexpected error occurred.');
    }
  }

  @override
  Future<ApiResult<bool>> requestWithdrawal({
    required String partnerId,
    required double amount,
    required BankDetailEntity bankDetail,
    String notes = 'Withdrawal',
  }) async {
    try {
      // Exactly the fields the 6 Nov app sends; no extra ones.
      final payload = {
        'partnerId': partnerId,
        'amount': amount,
        'paymentMethod': 'BANK',
        'accountDetails': {
          'accountName': bankDetail.accountHolderName,
          'accountNumber': bankDetail.accountNumber,
          'ifsc': bankDetail.ifscCode,
        },
        'notes': notes,
      };

      await remoteDataSource.requestWithdrawal(payload);
      return const ApiResult.success(true);
    } catch (e) {
      log('Error requesting withdrawal: $e');
      final text = e.toString().replaceFirst('Exception: ', '');
      return ApiResult.failure(text.isEmpty ? 'Unexpected error occurred.' : text);
    }
  }
}
