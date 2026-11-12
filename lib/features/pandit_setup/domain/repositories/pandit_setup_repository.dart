import '../../../../core/network/api_result.dart';
import '../entities/pandit_setup_entity.dart';

abstract class PanditSetupRepository {
  Future<ApiResult<List<PanditCategoryEntity>>> getCategories(String moduleId);
  Future<ApiResult<List<PanditServiceEntity>>> getServices(String categoryId, String moduleId);
}
