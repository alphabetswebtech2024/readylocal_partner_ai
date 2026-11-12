import '../models/payment_failure_model.dart';

abstract class PaymentFailedLocalDataSource {
  PaymentFailureModel getPaymentFailureDetails();
}

class PaymentFailedLocalDataSourceImpl implements PaymentFailedLocalDataSource {
  @override
  PaymentFailureModel getPaymentFailureDetails() {
    return const PaymentFailureModel();
  }
}
