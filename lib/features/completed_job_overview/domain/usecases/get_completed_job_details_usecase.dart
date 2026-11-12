import '../../../job_overview/domain/entities/job_overview_entity.dart';
import '../entities/completed_job_entity.dart';
import '../repositories/completed_job_repository.dart';

class GetCompletedJobDetailsUseCase {
  final CompletedJobRepository repository;

  GetCompletedJobDetailsUseCase(this.repository);

  CompletedJobEntity call(JobOverviewEntity job) {
    return repository.getCompletedJobDetails(job);
  }
}
