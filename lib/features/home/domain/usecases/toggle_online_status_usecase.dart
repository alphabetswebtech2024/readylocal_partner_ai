import '../../../../core/network/api_result.dart';
import '../repositories/home_repository.dart';

class ToggleOnlineStatusUseCase {
  final HomeRepository repository;

  ToggleOnlineStatusUseCase(this.repository);

  Future<ApiResult<bool>> call({
    required String partnerId,
    required bool isOnline,
  }) {
    return repository.toggleOnlineStatus(
      partnerId: partnerId,
      isOnline: isOnline,
    );
  }
}
