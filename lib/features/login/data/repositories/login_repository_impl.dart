import '../../../../core/network/api_result.dart';
import '../../domain/entities/login_result_entity.dart';
import '../../domain/repositories/login_repository.dart';
import '../datasources/login_remote_datasource.dart';

class LoginRepositoryImpl implements LoginRepository {
  final LoginRemoteDataSource remoteDataSource;

  LoginRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<LoginResultEntity>> sendOtp(String mobileNumber) async {
    try {
      final model = await remoteDataSource.sendOtp(mobileNumber);
      return ApiResult.success(model);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }
}
