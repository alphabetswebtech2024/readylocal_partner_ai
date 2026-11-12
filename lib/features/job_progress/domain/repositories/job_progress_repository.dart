import '../../../../core/network/api_result.dart';

abstract class JobProgressRepository {
  Future<ApiResult<String>> uploadWorkImage({
    required String filename,
    required String base64Data,
  });

  Future<ApiResult<bool>> cancelJob({
    required String partnerId,
    required String jobId,
    required String reason,
  });

  Future<ApiResult<bool>> completeJob({
    required String partnerId,
    required String jobId,
    required List<String> workPicUrls,
    required String reason,
  });
}
