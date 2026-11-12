import '../../../../core/network/api_result.dart';
import '../repositories/job_progress_repository.dart';

class CompleteJobUseCase {
  final JobProgressRepository repository;

  CompleteJobUseCase(this.repository);

  Future<ApiResult<bool>> call({
    required String partnerId,
    required String jobId,
    required List<String> workPicUrls,
    required String reason,
  }) {
    return repository.completeJob(
      partnerId: partnerId,
      jobId: jobId,
      workPicUrls: workPicUrls,
      reason: reason,
    );
  }
}
