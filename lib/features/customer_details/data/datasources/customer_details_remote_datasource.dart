import 'dart:convert';
import '../../../../core/network/api_constants.dart' as api;
import '../../../../core/network/api_service.dart';
import 'package:gotask_partner/core/network/api_response_check.dart';

abstract class CustomerDetailsRemoteDataSource {
  Future<bool> startRide(String partnerId, String requestId, String serviceId);
  Future<bool> reachLocation(String partnerId, String requestId, String serviceId);
  Future<bool> sendLiveLocation(
    String partnerId,
    String customerId,
    double lat,
    double long,
    String status,
  );
}

class CustomerDetailsRemoteDataSourceImpl implements CustomerDetailsRemoteDataSource {
  final ApiService _apiService;

  CustomerDetailsRemoteDataSourceImpl(this._apiService);

  @override
  Future<bool> startRide(String partnerId, String requestId, String serviceId) async {
    final response = await _apiService.post(
      api.startLocation_pat,
      data: jsonEncode({
        'partnerId': partnerId,
        'requestId': requestId,
        'serviceId': serviceId,
        'RequestID': requestId,
        'ServiceID': serviceId,
      }),
    );

    return apiCallSucceeded(response);
  }

  @override
  Future<bool> reachLocation(String partnerId, String requestId, String serviceId) async {
    final response = await _apiService.post(
      api.reachedLocation_pat,
      data: jsonEncode({
        'partnerId': partnerId,
        'requestId': requestId,
        'serviceId': serviceId,
        'RequestID': requestId,
        'ServiceID': serviceId,
      }),
    );

    return apiCallSucceeded(response);
  }

  @override
  Future<bool> sendLiveLocation(
    String partnerId,
    String customerId,
    double lat,
    double long,
    String status,
  ) async {
    final response = await _apiService.post(
      api.sendLocationData_pat,
      data: jsonEncode({
        "partnerId": partnerId,
        "lat": lat.toString(),
        "long": long.toString(),
        "customerId": customerId,
        "status": status,
      }),
    );

    return apiCallSucceeded(response);
  }
}
