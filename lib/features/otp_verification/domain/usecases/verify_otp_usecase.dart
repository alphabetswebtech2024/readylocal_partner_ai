import '../../../../core/network/api_result.dart';
import '../entities/otp_auth_entity.dart';
import '../repositories/otp_verification_repository.dart';

class VerifyOtpUseCase {
  final OtpVerificationRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<ApiResult<OtpAuthEntity>> call({
    required String mobileNumber,
    required String otp,
  }) {
    return repository.verifyOtp(mobileNumber: mobileNumber, otp: otp);
  }
}
