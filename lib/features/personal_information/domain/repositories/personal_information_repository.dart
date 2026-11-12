import '../../../../core/network/api_result.dart';
import '../entities/personal_info_entity.dart';

abstract class PersonalInformationRepository {
  Future<ApiResult<PersonalInfoEntity>> savePersonalInfo(Map<String, dynamic> requestData);
}
