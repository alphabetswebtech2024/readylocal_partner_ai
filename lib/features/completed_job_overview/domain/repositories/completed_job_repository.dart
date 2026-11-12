import '../../../job_overview/domain/entities/job_overview_entity.dart';
import '../entities/completed_job_entity.dart';

abstract class CompletedJobRepository {
  CompletedJobEntity getCompletedJobDetails(JobOverviewEntity job);
}
