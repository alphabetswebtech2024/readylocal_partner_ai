import 'dart:convert';
import '../../../../core/network/api_constants.dart' as api;
import '../../../../core/network/api_service.dart';
import 'package:gotask_partner/core/network/api_response_check.dart';

abstract class JobOverviewRemoteDataSource {
  Future<bool> acceptJob(String partnerId, String jobId, String serviceId);
  Future<bool> rejectJob(String partnerId, String jobId, String reason);
}

class JobOverviewRemoteDataSourceImpl implements JobOverviewRemoteDataSource {
  final ApiService _apiService;

  JobOverviewRemoteDataSourceImpl(this._apiService);

  @override
  Future<bool> acceptJob(String partnerId, String jobId, String serviceId) async {
    final response = await _apiService.post(
      api.acceptedJob,
      data: jsonEncode({
        'partnerId': partnerId,
        'jobId': jobId,
        'JobId': jobId, // the server's own error text asks for "JobId"
        'serviceId': serviceId,
        'ServiceID': serviceId,
        'Status': 'ACCEPTED',
      }),
    );

    return apiCallSucceeded(response);
  }

  @override
  Future<bool> rejectJob(String partnerId, String jobId, String reason) async {
    final response = await _apiService.post(
      api.rejectedJob,
      data: jsonEncode({
        'partnerId': partnerId,
        'jobId': jobId,
        'JobId': jobId,
        'reason': reason,
      }),
    );

    return apiCallSucceeded(response);
  }
}
