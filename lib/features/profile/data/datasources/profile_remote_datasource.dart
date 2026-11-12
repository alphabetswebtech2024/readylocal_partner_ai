import 'dart:convert';
import '../../../../core/network/api_constants.dart' as api;
import '../../../../core/network/api_service.dart';

abstract class ProfileRemoteDataSource {
  Future<Map<String, dynamic>> getPartnerRawDetails(String partnerId);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiService _apiService;

  ProfileRemoteDataSourceImpl(this._apiService);

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
}
