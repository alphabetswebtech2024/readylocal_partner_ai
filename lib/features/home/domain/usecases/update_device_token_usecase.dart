import '../../../../core/network/api_result.dart';
import '../repositories/home_repository.dart';

class UpdateDeviceTokenUseCase {
  final HomeRepository repository;

  UpdateDeviceTokenUseCase(this.repository);

  Future<ApiResult<bool>> call({
    required String partnerId,
    required String deviceToken,
  }) {
    return repository.updateDeviceToken(
      partnerId: partnerId,
      deviceToken: deviceToken,
    );
  }
}
