import '../../../job_overview/domain/entities/job_overview_entity.dart';
import '../../domain/entities/completed_job_entity.dart';
import '../../domain/repositories/completed_job_repository.dart';
import '../datasources/completed_job_local_datasource.dart';

class CompletedJobRepositoryImpl implements CompletedJobRepository {
  final CompletedJobLocalDataSource localDataSource;

  CompletedJobRepositoryImpl(this.localDataSource);

  @override
  CompletedJobEntity getCompletedJobDetails(JobOverviewEntity job) {
    return localDataSource.getJob(job);
  }
}
