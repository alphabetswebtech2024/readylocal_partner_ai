import '../../../../core/network/api_result.dart';
import '../entities/home_dashboard_entity.dart';
import '../repositories/home_repository.dart';

class GetHomeDetailsUseCase {
  final HomeRepository repository;

  GetHomeDetailsUseCase(this.repository);

  Future<ApiResult<HomeDashboardEntity>> call(String partnerId) {
    return repository.getPartnerHomeDashboard(partnerId);
  }

  Future<HomeDashboardEntity?> saved(String partnerId) => repository.savedDashboard(partnerId);
}
