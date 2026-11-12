import '../../../../core/network/api_result.dart';
import '../../../../core/network/token_storage.dart';
import '../../../../core/session/app_session.dart';
import '../../domain/entities/otp_auth_entity.dart';
import '../../domain/repositories/otp_verification_repository.dart';
import '../datasources/otp_verification_remote_datasource.dart';

class OtpVerificationRepositoryImpl implements OtpVerificationRepository {
  final OtpVerificationRemoteDataSource remoteDataSource;

  OtpVerificationRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<OtpAuthEntity>> verifyOtp({
    required String mobileNumber,
    required String otp,
  }) async {
    try {
      final model = await remoteDataSource.verifyOtp(mobileNumber: mobileNumber, otp: otp);
      if (model.token.isNotEmpty) {
        await TokenStorage.saveToken(model.token);
      }
      AppSession.setUser(model.user);
      return ApiResult.success(model);
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '').trim();
      return ApiResult.failure(msg.isNotEmpty ? msg : 'Invalid OTP. Please try again.');
    }
  }

  @override
  Future<ApiResult<bool>> resendOtp(String mobileNumber) async {
    try {
      final success = await remoteDataSource.resendOtp(mobileNumber);
      return ApiResult.success(success);
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '').trim();
      return ApiResult.failure(msg.isNotEmpty ? msg : 'Failed to resend OTP');
    }
  }
}
