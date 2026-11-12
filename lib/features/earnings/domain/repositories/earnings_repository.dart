import '../../../../core/network/api_result.dart';
import '../entities/earnings_details_entity.dart';

abstract class EarningsRepository {
  Future<ApiResult<EarningsDetailsEntity>> getEarningsDetails(String partnerId);
}
