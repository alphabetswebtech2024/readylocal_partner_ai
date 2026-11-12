import '../../../../core/network/api_result.dart';
import '../entities/login_result_entity.dart';

abstract class LoginRepository {
  Future<ApiResult<LoginResultEntity>> sendOtp(String mobileNumber);
}
