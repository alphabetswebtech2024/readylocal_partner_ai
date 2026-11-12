import 'dart:convert';
import '../../../../core/network/api_constants.dart' as api;
import '../../../../core/network/api_service.dart';
import 'package:gotask_partner/core/network/api_response_check.dart';

abstract class HomeRemoteDataSource {
  Future<Map<String, dynamic>> getPartnerRawDetails(String partnerId);
  Future<bool> updateOnlineStatus(String partnerId, String status);
  Future<bool> sendLocation(String partnerId, double lat, double long, String status);
  Future<bool> updateDeviceToken(String partnerId, String deviceToken);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final ApiService _apiService;

  HomeRemoteDataSourceImpl(this._apiService);

  @override
  Future<Map<String, dynamic>> getPartnerRawDetails(String partnerId) async {
    final response = await _apiService.post(
      api.getPartnerDetails,
      data: jsonEncode({'partnerId': partnerId}),
    );

    final body = response.data;
    if (body is! Map) {
      throw Exception('Invalid response format.');
    }

    if (body['Data'] == null || (body['Data'] is Map && (body['Data'] as Map).isEmpty)) {
      throw Exception('Empty data received.');
    }

    return body['Data'] as Map<String, dynamic>;
  }

  @override
  Future<bool> updateOnlineStatus(String partnerId, String status) async {
    final response = await _apiService.post(
      api.partnerOnOrOff,
      data: {
        'partnerID': partnerId,
        'status': status,
      },
    );

    return apiCallSucceeded(response);
  }

  @override
  Future<bool> sendLocation(String partnerId, double lat, double long, String status) async {
    final response = await _apiService.post(
      api.sendLocationData,
      data: jsonEncode({
        "partnerId": partnerId,
        "lat": lat.toString(),
        "long": long.toString(),
        "customerId": "",
        "status": status,
      }),
    );

    return apiCallSucceeded(response);
  }

  @override
  Future<bool> updateDeviceToken(String partnerId, String deviceToken) async {
    final response = await _apiService.post(
      api.updateDeviceToken,
      data: jsonEncode({
        'deviceToken': deviceToken,
        'partnerID': partnerId,
      }),
    );

    return apiCallSucceeded(response);
  }
}
