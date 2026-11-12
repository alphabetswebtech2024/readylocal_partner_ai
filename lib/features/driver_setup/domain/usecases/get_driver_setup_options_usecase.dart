import '../../../../core/network/api_result.dart';
import '../entities/driver_setup_entity.dart';
import '../repositories/driver_setup_repository.dart';

class GetDriverSetupOptionsUseCase {
  final DriverSetupRepository repository;

  GetDriverSetupOptionsUseCase(this.repository);

  Future<ApiResult<DriverSetupOptionsEntity>> call() {
    return repository.getDriverSetupOptions();
  }
}
