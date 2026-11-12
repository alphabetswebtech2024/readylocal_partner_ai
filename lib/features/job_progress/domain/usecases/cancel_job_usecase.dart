import '../../../../core/network/api_result.dart';
import '../repositories/job_progress_repository.dart';

class CancelJobUseCase {
  final JobProgressRepository repository;

  CancelJobUseCase(this.repository);

  Future<ApiResult<bool>> call({
    required String partnerId,
    required String jobId,
    required String reason,
  }) {
    return repository.cancelJob(
      partnerId: partnerId,
      jobId: jobId,
      reason: reason,
    );
  }
}
