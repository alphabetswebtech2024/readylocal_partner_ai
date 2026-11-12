import '../../../../core/network/api_result.dart';

abstract class ActivationFeeRepository {
  Future<ApiResult<bool>> saveTransaction({
    required String partnerId,
    required String transactionId,
    required double amount,
    required String moduleId,
    required String moduleName,
  });
}
