import '../../../../core/network/api_result.dart';
import '../../domain/repositories/activation_fee_repository.dart';
import '../datasources/activation_fee_remote_datasource.dart';

class ActivationFeeRepositoryImpl implements ActivationFeeRepository {
  final ActivationFeeRemoteDataSource remoteDataSource;

  ActivationFeeRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<bool>> saveTransaction({
    required String partnerId,
    required String transactionId,
    required double amount,
    required String moduleId,
    required String moduleName,
  }) async {
    try {
      final success = await remoteDataSource.saveTransaction(
        partnerId: partnerId,
        transactionId: transactionId,
        amount: amount,
        moduleId: moduleId,
        moduleName: moduleName,
      );
      if (success) {
        return const ApiResult.success(true);
      }
      return const ApiResult.failure('Failed to save transaction');
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }
}
