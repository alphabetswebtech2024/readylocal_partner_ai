import '../../../../core/network/api_result.dart';
import '../entities/job_item_entity.dart';

abstract class JobsListRepository {
  Future<ApiResult<List<JobItemEntity>>> getJobsList(String partnerId);
}
