import '../../../../core/network/api_result.dart';
import '../repositories/otp_verification_repository.dart';

class ResendOtpUseCase {
  final OtpVerificationRepository repository;

  ResendOtpUseCase(this.repository);

  Future<ApiResult<bool>> call(String mobileNumber) {
    return repository.resendOtp(mobileNumber);
  }
}
