import '../../../../core/network/api_result.dart';
import '../entities/service_module_entity.dart';
import '../repositories/select_service_repository.dart';

class GetServiceModulesUseCase {
  final SelectServiceRepository repository;

  GetServiceModulesUseCase(this.repository);

  Future<ApiResult<List<ServiceModuleEntity>>> call() {
    return repository.getModules();
  }
}

class GetServiceRegistrationFeesUseCase {
  final SelectServiceRepository repository;

  GetServiceRegistrationFeesUseCase(this.repository);

  Future<ApiResult<Map<String, double>>> call(String partnerId) {
    return repository.getRegistrationFees(partnerId);
  }
}
