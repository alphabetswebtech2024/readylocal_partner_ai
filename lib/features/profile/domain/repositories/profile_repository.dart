import '../../../../core/network/api_result.dart';
import '../entities/partner_profile_data_entity.dart';

abstract class ProfileRepository {
  Future<ApiResult<PartnerProfileDataEntity>> getPartnerProfile(String partnerId);
}
