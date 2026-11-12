import '../../../../core/network/api_result.dart';
import '../entities/partner_profile_data_entity.dart';
import '../repositories/profile_repository.dart';

class GetPartnerProfileUseCase {
  final ProfileRepository repository;

  GetPartnerProfileUseCase(this.repository);

  Future<ApiResult<PartnerProfileDataEntity>> call(String partnerId) {
    return repository.getPartnerProfile(partnerId);
  }
}
