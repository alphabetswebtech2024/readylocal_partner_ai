import '../../../../core/network/api_result.dart';
import '../entities/view_profile_entity.dart';

abstract class ViewProfileRepository {
  Future<ApiResult<ViewProfileEntity>> getViewProfileDetails(String partnerId);
}
