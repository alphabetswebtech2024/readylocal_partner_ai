import 'dart:developer';
import '../../../../core/network/api_result.dart';
import '../../domain/entities/job_item_entity.dart';
import '../../domain/repositories/jobs_list_repository.dart';
import '../datasources/jobs_list_remote_datasource.dart';
import '../models/job_item_model.dart';

class JobsListRepositoryImpl implements JobsListRepository {
  final JobsListRemoteDataSource remoteDataSource;

  JobsListRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<List<JobItemEntity>>> getJobsList(String partnerId) async {
    try {
      final rawData = await remoteDataSource.getPartnerRawDetails(partnerId);
      final rawJobsList = rawData['AcceptOrReject'] as List<dynamic>? ?? [];

      final jobs = rawJobsList
          .map((e) => JobItemModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return ApiResult.success(jobs);
    } catch (e) {
      log('Error fetching jobs list: $e');
      return ApiResult.failure(e is Exception ? e.toString() : 'Unexpected error occurred.');
    }
  }
}
