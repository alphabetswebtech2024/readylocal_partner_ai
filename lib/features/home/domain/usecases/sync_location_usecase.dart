import '../../../../core/network/api_result.dart';
import '../repositories/home_repository.dart';

class SyncLocationUseCase {
  final HomeRepository repository;

  SyncLocationUseCase(this.repository);

  Future<ApiResult<bool>> call({
    required String partnerId,
    required double latitude,
    required double longitude,
    required bool isOnline,
  }) {
    return repository.syncLocation(
      partnerId: partnerId,
      latitude: latitude,
      longitude: longitude,
      isOnline: isOnline,
    );
  }
}
