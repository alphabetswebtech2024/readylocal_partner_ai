import 'dart:convert';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_service.dart';
import '../models/splash_partner_status_model.dart';

abstract class SplashRemoteDataSource {
  Future<SplashPartnerStatusModel> getPartnerStatus(String partnerId);
}

class SplashRemoteDataSourceImpl implements SplashRemoteDataSource {
  final ApiService _apiService;

  SplashRemoteDataSourceImpl(this._apiService);

  @override
  Future<SplashPartnerStatusModel> getPartnerStatus(String partnerId) async {
    final response = await _apiService.post(
      getPartnerDetails,
      data: jsonEncode({'partnerId': partnerId}),
    );

    final raw = response.data;
    final Map<String, dynamic> decoded = raw is Map<String, dynamic>
        ? raw
        : (raw is String ? jsonDecode(raw) : <String, dynamic>{});

    if (decoded['Status'] == 'SUCCESS' && decoded['Data'] != null) {
      return SplashPartnerStatusModel.fromJson(Map<String, dynamic>.from(decoded['Data']));
    }
    throw Exception('Invalid partner status response');
  }
}
