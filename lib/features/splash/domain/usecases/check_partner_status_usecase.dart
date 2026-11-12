import '../../../../core/network/api_result.dart';
import '../entities/splash_partner_status_entity.dart';
import '../repositories/splash_repository.dart';

class CheckPartnerStatusUseCase {
  final SplashRepository repository;

  CheckPartnerStatusUseCase(this.repository);

  Future<ApiResult<SplashPartnerStatusEntity>> call(String partnerId) {
    return repository.checkPartnerStatus(partnerId);
  }
}
