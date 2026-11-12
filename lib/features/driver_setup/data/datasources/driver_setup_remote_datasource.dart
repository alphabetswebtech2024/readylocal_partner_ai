import '../../../../core/network/api_constants.dart' as api;
import '../../../../core/network/api_rows.dart';
import '../../../../core/network/catalog_cache.dart';
import '../../../../core/network/api_service.dart';
import '../models/driver_setup_model.dart';

abstract class DriverSetupRemoteDataSource {
  Future<DriverSetupOptionsModel> getDriverSetupOptions();
}

class DriverSetupRemoteDataSourceImpl implements DriverSetupRemoteDataSource {
  final ApiService _apiService;

  DriverSetupRemoteDataSourceImpl(this._apiService);

  /// Driver setup uses four separate APIs. If one fails, its section is simply
  /// empty and the others still load.
  Future<List<Map<String, dynamic>>> _rows(String url, String key) async {
    try {
      final reply = await CatalogCache.get(_apiService, url);
      return rowsOf(reply, [key], activeOnly: false);
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<DriverSetupOptionsModel> getDriverSetupOptions() async {
    final lists = await Future.wait([
      _rows(api.getDriverServiceTypes, 'driverServiceTypes'),
      _rows(api.getDriverLicenseTypes, 'drivigLicenseTypes'), // the server's own spelling
      _rows(api.getVehicleTypesAPI, 'vehicleTypes'),
      _rows(api.getSafetySkillsAPI, 'safetySkills'),
    ]);
    return DriverSetupOptionsModel.fromJson({
      'driverServiceTypes': lists[0],
      'driverLicenseTypes': lists[1],
      'vehicleTypes': lists[2],
      'safetySkills': lists[3],
    });
  }
}
