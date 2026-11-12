import '../../../../core/network/api_result.dart';
import '../entities/personal_info_entity.dart';
import '../repositories/personal_information_repository.dart';

class SavePersonalInfoUseCase {
  final PersonalInformationRepository repository;

  SavePersonalInfoUseCase(this.repository);

  Future<ApiResult<PersonalInfoEntity>> call(Map<String, dynamic> requestData) {
    return repository.savePersonalInfo(requestData);
  }
}
