import '../../../../core/network/api_result.dart';
import '../entities/work_status_success_entity.dart';
import '../repositories/work_status_success_repository.dart';

class GetWorkStatusSuccessDetailsUseCase {
  final WorkStatusSuccessRepository repository;

  GetWorkStatusSuccessDetailsUseCase(this.repository);

  Future<ApiResult<WorkStatusSuccessEntity>> call(String partnerName) {
    return repository.getSuccessDetails(partnerName);
  }
}
