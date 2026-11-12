import '../../../../core/network/api_result.dart';
import '../repositories/job_overview_repository.dart';

class RejectJobUseCase {
  final JobOverviewRepository repository;

  RejectJobUseCase(this.repository);

  Future<ApiResult<bool>> call({
    required String partnerId,
    required String jobId,
    required String reason,
  }) {
    return repository.rejectJob(
      partnerId: partnerId,
      jobId: jobId,
      reason: reason,
    );
  }
}
