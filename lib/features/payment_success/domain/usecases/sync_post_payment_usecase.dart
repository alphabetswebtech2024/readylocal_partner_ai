import '../../../../core/network/api_result.dart';
import '../entities/payment_success_entity.dart';
import '../repositories/payment_success_repository.dart';

class SyncPostPaymentUseCase {
  final PaymentSuccessRepository repository;

  SyncPostPaymentUseCase(this.repository);

  Future<ApiResult<PaymentSuccessEntity>> call({
    required String partnerId,
    required String deviceToken,
  }) {
    return repository.syncPostPayment(partnerId: partnerId, deviceToken: deviceToken);
  }
}
