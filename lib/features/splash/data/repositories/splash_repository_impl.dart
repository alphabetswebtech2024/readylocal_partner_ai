import '../../../../core/network/api_result.dart';
import '../../domain/entities/splash_partner_status_entity.dart';
import '../../domain/repositories/splash_repository.dart';
import '../datasources/splash_remote_datasource.dart';

class SplashRepositoryImpl implements SplashRepository {
  final SplashRemoteDataSource remoteDataSource;

  SplashRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<SplashPartnerStatusEntity>> checkPartnerStatus(String partnerId) async {
    try {
      final model = await remoteDataSource.getPartnerStatus(partnerId);
      return ApiResult.success(model);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }
}
