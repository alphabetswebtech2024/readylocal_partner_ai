import '../../../../core/network/api_result.dart';
import '../entities/splash_partner_status_entity.dart';

abstract class SplashRepository {
  Future<ApiResult<SplashPartnerStatusEntity>> checkPartnerStatus(String partnerId);
}
