import '../../../../core/network/api_result.dart';
import '../entities/driver_setup_entity.dart';

abstract class DriverSetupRepository {
  Future<ApiResult<DriverSetupOptionsEntity>> getDriverSetupOptions();
}
