import '../../../../core/network/api_result.dart';
import '../entities/job_item_entity.dart';
import '../repositories/jobs_list_repository.dart';

class GetJobsListUseCase {
  final JobsListRepository repository;

  GetJobsListUseCase(this.repository);

  Future<ApiResult<List<JobItemEntity>>> call(String partnerId) {
    return repository.getJobsList(partnerId);
  }
}
