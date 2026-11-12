import '../../../../core/network/api_result.dart';
import '../repositories/customer_details_repository.dart';

class ReachLocationUseCase {
  final CustomerDetailsRepository repository;

  ReachLocationUseCase(this.repository);

  Future<ApiResult<bool>> call({
    required String partnerId,
    required String requestId,
    required String serviceId,
  }) {
    return repository.reachLocation(
      partnerId: partnerId,
      requestId: requestId,
      serviceId: serviceId,
    );
  }
}
