import 'dart:developer';
import '../../../../core/network/api_result.dart';
import '../../domain/repositories/job_overview_repository.dart';
import '../datasources/job_overview_remote_datasource.dart';

class JobOverviewRepositoryImpl implements JobOverviewRepository {
  final JobOverviewRemoteDataSource remoteDataSource;

  JobOverviewRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<bool>> acceptJob({
    required String partnerId,
    required String jobId,
    required String serviceId,
  }) async {
    try {
      final success = await remoteDataSource.acceptJob(partnerId, jobId, serviceId);
      if (success) {
        return const ApiResult.success(true);
      }
      return const ApiResult.failure('Failed to accept job.');
    } catch (e) {
      log('Error accepting job: $e');
      return ApiResult.failure(e is Exception ? e.toString() : 'Unexpected error occurred.');
    }
  }

  @override
  Future<ApiResult<bool>> rejectJob({
    required String partnerId,
    required String jobId,
    required String reason,
  }) async {
    try {
      final success = await remoteDataSource.rejectJob(partnerId, jobId, reason);
      if (success) {
        return const ApiResult.success(true);
      }
      return const ApiResult.failure('Failed to reject job.');
    } catch (e) {
      log('Error rejecting job: $e');
      return ApiResult.failure(e is Exception ? e.toString() : 'Unexpected error occurred.');
    }
  }
}
