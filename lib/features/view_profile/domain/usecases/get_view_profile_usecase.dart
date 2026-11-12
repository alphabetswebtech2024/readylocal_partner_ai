import '../../../../core/network/api_result.dart';
import '../entities/view_profile_entity.dart';
import '../repositories/view_profile_repository.dart';

class GetViewProfileUseCase {
  final ViewProfileRepository repository;

  GetViewProfileUseCase(this.repository);

  Future<ApiResult<ViewProfileEntity>> call(String partnerId) {
    return repository.getViewProfileDetails(partnerId);
  }
}
