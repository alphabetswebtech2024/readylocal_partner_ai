import 'dart:convert';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_service.dart';
import '../models/login_result_model.dart';

abstract class LoginRemoteDataSource {
  Future<LoginResultModel> sendOtp(String mobileNumber);
}

class LoginRemoteDataSourceImpl implements LoginRemoteDataSource {
  final ApiService _apiService;

  LoginRemoteDataSourceImpl(this._apiService);

  @override
  Future<LoginResultModel> sendOtp(String mobileNumber) async {
    final response = await _apiService.post(
      ApiConstants.partnerOtp,
      data: {'MobileNumber': mobileNumber},
    );

    final dynamic raw = response.data;
    final Map<String, dynamic> data = raw is Map<String, dynamic>
        ? raw
        : (raw is String ? jsonDecode(raw) : <String, dynamic>{});

    if (data['Status'] == 'SUCCESS') {
      return LoginResultModel.fromJson(data);
    }
    throw Exception(data['ResponseMsg'] ?? 'Failed to send OTP');
  }
}
