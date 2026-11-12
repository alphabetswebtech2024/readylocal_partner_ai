import 'dart:convert';
import 'dart:developer' as developer;
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_service.dart';
import '../models/otp_auth_model.dart';

abstract class OtpVerificationRemoteDataSource {
  Future<OtpAuthModel> verifyOtp({
    required String mobileNumber,
    required String otp,
  });

  Future<bool> resendOtp(String mobileNumber);
}

class OtpVerificationRemoteDataSourceImpl implements OtpVerificationRemoteDataSource {
  final ApiService _apiService;

  OtpVerificationRemoteDataSourceImpl(this._apiService);

  @override
  Future<OtpAuthModel> verifyOtp({
    required String mobileNumber,
    required String otp,
  }) async {
    developer.log("Validating OTP for $mobileNumber: $otp");

    final response = await _apiService.post(
      ApiConstants.partnerValidateOtp,
      data: {
        'MobileNumber': mobileNumber,
        'OTP': otp,
      },
    );

    final dynamic raw = response.data;
    developer.log("partnerValidateOTP response: $raw");

    final Map<String, dynamic> data = raw is Map<String, dynamic>
        ? raw
        : (raw is String ? jsonDecode(raw) : <String, dynamic>{});

    final String? status = data['Status']?.toString().toUpperCase();
    final dynamic statusCode = data['StatusCode'] ?? data['statusCode'];

    final bool isExplicitFailure = status == 'FAILED' ||
        status == 'FAILURE' ||
        status == 'ERROR' ||
        statusCode == 400 ||
        statusCode == 401 ||
        statusCode == 403;

    final bool hasUserData = data['UserData'] != null ||
        data['Data'] != null ||
        data['data'] != null ||
        data['user'] != null ||
        data['User'] != null ||
        (data['_id'] != null && data['_id'].toString().isNotEmpty);

    final bool isSuccess = !isExplicitFailure &&
        (status == 'SUCCESS' ||
            statusCode == 200 ||
            statusCode == '200' ||
            response.statusCode == 200);

    if (isSuccess && (hasUserData || status == 'SUCCESS')) {
      return OtpAuthModel.fromJson(data);
    }

    final String errorMsg = (data['Message'] ??
            data['message'] ??
            data['ResponseMsg'] ??
            data['responseMsg'] ??
            data['error'] ??
            'Invalid OTP. Please try again.')
        .toString();

    throw Exception(errorMsg);
  }

  @override
  Future<bool> resendOtp(String mobileNumber) async {
    developer.log("Resending OTP for $mobileNumber");

    final response = await _apiService.post(
      ApiConstants.partnerOtp,
      data: {'MobileNumber': mobileNumber},
    );

    final dynamic raw = response.data;
    developer.log("partnerOtp response: $raw");

    final Map<String, dynamic> data = raw is Map<String, dynamic>
        ? raw
        : (raw is String ? jsonDecode(raw) : <String, dynamic>{});

    final String? status = data['Status']?.toString().toUpperCase();
    final dynamic statusCode = data['StatusCode'] ?? data['statusCode'];

    return status == 'SUCCESS' ||
        statusCode == 200 ||
        statusCode == '200' ||
        response.statusCode == 200;
  }
}
