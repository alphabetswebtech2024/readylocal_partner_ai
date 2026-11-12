import '../../../../core/network/api_result.dart';
import '../entities/service_module_entity.dart';

abstract class SelectServiceRepository {
  Future<ApiResult<List<ServiceModuleEntity>>> getModules();
  Future<ApiResult<Map<String, double>>> getRegistrationFees(String partnerId);
}
