import '../../../../core/models/User.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/session/app_session.dart';
import '../../domain/entities/personal_info_entity.dart';
import '../../domain/repositories/personal_information_repository.dart';
import '../datasources/personal_information_remote_datasource.dart';

class PersonalInformationRepositoryImpl implements PersonalInformationRepository {
  final PersonalInformationRemoteDataSource remoteDataSource;

  PersonalInformationRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<PersonalInfoEntity>> savePersonalInfo(Map<String, dynamic> requestData) async {
    try {
      final model = await remoteDataSource.updateProfile(requestData);
      // The response may not carry a full user; never blank the signed-in partner.
      if (model.user.id.isNotEmpty) AppSession.setUser(model.user);
      return ApiResult.success(model);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }
}
