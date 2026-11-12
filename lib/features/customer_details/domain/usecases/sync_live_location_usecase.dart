import '../../../../core/network/api_result.dart';
import '../repositories/customer_details_repository.dart';

class SyncLiveLocationUseCase {
  final CustomerDetailsRepository repository;

  SyncLiveLocationUseCase(this.repository);

  Future<ApiResult<bool>> call({
    required String partnerId,
    required String customerId,
    required double latitude,
    required double longitude,
    required String status,
  }) {
    return repository.syncLiveLocation(
      partnerId: partnerId,
      customerId: customerId,
      latitude: latitude,
      longitude: longitude,
      status: status,
    );
  }
}
