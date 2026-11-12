import '../../../../core/network/api_result.dart';
import '../../domain/repositories/job_progress_repository.dart';
import '../datasources/job_progress_remote_datasource.dart';

class JobProgressRepositoryImpl implements JobProgressRepository {
  final JobProgressRemoteDataSource remoteDataSource;

  JobProgressRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<String>> uploadWorkImage({
    required String filename,
    required String base64Data,
  }) async {
    try {
      final result = await remoteDataSource.uploadWorkImage(
        filename: filename,
        base64Data: base64Data,
      );
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  @override
  Future<ApiResult<bool>> cancelJob({
    required String partnerId,
    required String jobId,
    required String reason,
  }) async {
    try {
      final result = await remoteDataSource.cancelJob(
        partnerId: partnerId,
        jobId: jobId,
        reason: reason,
      );
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  @override
  Future<ApiResult<bool>> completeJob({
    required String partnerId,
    required String jobId,
    required List<String> workPicUrls,
    required String reason,
  }) async {
    try {
      final result = await remoteDataSource.completeJob(
        partnerId: partnerId,
        jobId: jobId,
        workPicUrls: workPicUrls,
        reason: reason,
      );
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }
}
