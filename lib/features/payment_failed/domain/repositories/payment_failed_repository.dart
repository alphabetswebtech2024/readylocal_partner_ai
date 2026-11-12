import '../entities/payment_failure_entity.dart';

abstract class PaymentFailedRepository {
  PaymentFailureEntity getFailureDetails();
}
