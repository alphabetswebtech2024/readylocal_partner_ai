import '../../../../core/network/api_result.dart';
import '../repositories/customer_details_repository.dart';

class StartRideUseCase {
  final CustomerDetailsRepository repository;

  StartRideUseCase(this.repository);

  Future<ApiResult<bool>> call({
    required String partnerId,
    required String requestId,
    required String serviceId,
  }) {
    return repository.startRide(
      partnerId: partnerId,
      requestId: requestId,
      serviceId: serviceId,
    );
  }
}
