import '../../../job_overview/domain/entities/job_overview_entity.dart';
import '../models/completed_job_model.dart';

abstract class CompletedJobLocalDataSource {
  CompletedJobModel getJob(JobOverviewEntity job);
}

class CompletedJobLocalDataSourceImpl implements CompletedJobLocalDataSource {
  @override
  CompletedJobModel getJob(JobOverviewEntity job) {
    return CompletedJobModel(job: job);
  }
}
