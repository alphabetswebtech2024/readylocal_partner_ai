import '../../../../core/network/api_result.dart';

abstract class JobOverviewRepository {
  Future<ApiResult<bool>> acceptJob({
    required String partnerId,
    required String jobId,
    required String serviceId,
  });

  Future<ApiResult<bool>> rejectJob({
    required String partnerId,
    required String jobId,
    required String reason,
  });
}
