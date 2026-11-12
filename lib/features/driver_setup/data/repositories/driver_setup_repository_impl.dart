import '../../../../core/network/api_result.dart';
import '../../domain/entities/driver_setup_entity.dart';
import '../../domain/repositories/driver_setup_repository.dart';
import '../datasources/driver_setup_remote_datasource.dart';

class DriverSetupRepositoryImpl implements DriverSetupRepository {
  final DriverSetupRemoteDataSource remoteDataSource;

  DriverSetupRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<DriverSetupOptionsEntity>> getDriverSetupOptions() async {
    try {
      final options = await remoteDataSource.getDriverSetupOptions();
      return ApiResult.success(options);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }
}
