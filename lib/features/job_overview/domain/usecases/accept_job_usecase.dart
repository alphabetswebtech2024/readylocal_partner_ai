import '../../../../core/network/api_result.dart';
import '../repositories/job_overview_repository.dart';

class AcceptJobUseCase {
  final JobOverviewRepository repository;

  AcceptJobUseCase(this.repository);

  Future<ApiResult<bool>> call({
    required String partnerId,
    required String jobId,
    required String serviceId,
  }) {
    return repository.acceptJob(
      partnerId: partnerId,
      jobId: jobId,
      serviceId: serviceId,
    );
  }
}
