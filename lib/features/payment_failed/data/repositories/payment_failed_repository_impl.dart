import '../../domain/entities/payment_failure_entity.dart';
import '../../domain/repositories/payment_failed_repository.dart';
import '../datasources/payment_failed_local_datasource.dart';

class PaymentFailedRepositoryImpl implements PaymentFailedRepository {
  final PaymentFailedLocalDataSource localDataSource;

  PaymentFailedRepositoryImpl({required this.localDataSource});

  @override
  PaymentFailureEntity getFailureDetails() {
    return localDataSource.getPaymentFailureDetails();
  }
}
