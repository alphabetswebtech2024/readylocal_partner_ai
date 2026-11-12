import '../../../../core/network/api_result.dart';
import '../../domain/entities/payment_success_entity.dart';
import '../../domain/repositories/payment_success_repository.dart';
import '../datasources/payment_success_remote_datasource.dart';

class PaymentSuccessRepositoryImpl implements PaymentSuccessRepository {
  final PaymentSuccessRemoteDataSource remoteDataSource;

  PaymentSuccessRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<PaymentSuccessEntity>> syncPostPayment({
    required String partnerId,
    required String deviceToken,
  }) async {
    try {
      final model = await remoteDataSource.updateDeviceToken(
        partnerId: partnerId,
        deviceToken: deviceToken,
      );
      return ApiResult.success(model);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }
}
