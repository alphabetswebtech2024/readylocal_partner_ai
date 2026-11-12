import '../../../../core/network/api_result.dart';
import '../repositories/notification_repository.dart';

class GetJobRequestDetailsUseCase {
  final NotificationRepository repository;

  GetJobRequestDetailsUseCase(this.repository);

  Future<ApiResult<Map<String, dynamic>?>> call(
    String requestId, [
    String serviceId = '',
  ]) {
    return repository.getJobRequestDetails(requestId, serviceId);
  }
}
