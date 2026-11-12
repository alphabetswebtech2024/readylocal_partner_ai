import '../../../../core/network/api_result.dart';
import '../entities/login_result_entity.dart';
import '../repositories/login_repository.dart';

class SendLoginOtpUseCase {
  final LoginRepository repository;

  SendLoginOtpUseCase(this.repository);

  Future<ApiResult<LoginResultEntity>> call(String mobileNumber) {
    return repository.sendOtp(mobileNumber);
  }
}
