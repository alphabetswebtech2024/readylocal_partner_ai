import '../../../../core/network/api_result.dart';
import '../entities/earnings_details_entity.dart';
import '../repositories/earnings_repository.dart';

class GetEarningsUseCase {
  final EarningsRepository repository;

  GetEarningsUseCase(this.repository);

  Future<ApiResult<EarningsDetailsEntity>> call(String partnerId) {
    return repository.getEarningsDetails(partnerId);
  }
}
