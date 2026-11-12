import '../../../../core/network/api_result.dart';
import '../entities/otp_auth_entity.dart';

abstract class OtpVerificationRepository {
  Future<ApiResult<OtpAuthEntity>> verifyOtp({
    required String mobileNumber,
    required String otp,
  });

  Future<ApiResult<bool>> resendOtp(String mobileNumber);
}
