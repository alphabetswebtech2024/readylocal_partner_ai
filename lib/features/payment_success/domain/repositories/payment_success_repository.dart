import '../../../../core/network/api_result.dart';
import '../entities/payment_success_entity.dart';

abstract class PaymentSuccessRepository {
  Future<ApiResult<PaymentSuccessEntity>> syncPostPayment({
    required String partnerId,
    required String deviceToken,
  });
}
