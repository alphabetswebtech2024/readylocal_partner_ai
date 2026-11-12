import '../../../../core/network/api_result.dart';
import '../entities/work_status_success_entity.dart';

abstract class WorkStatusSuccessRepository {
  Future<ApiResult<WorkStatusSuccessEntity>> getSuccessDetails(String partnerName);
}
