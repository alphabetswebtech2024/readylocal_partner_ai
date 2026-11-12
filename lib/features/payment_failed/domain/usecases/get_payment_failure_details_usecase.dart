import '../entities/payment_failure_entity.dart';
import '../repositories/payment_failed_repository.dart';

class GetPaymentFailureDetailsUseCase {
  final PaymentFailedRepository repository;

  GetPaymentFailureDetailsUseCase({required this.repository});

  PaymentFailureEntity call() {
    return repository.getFailureDetails();
  }
}
