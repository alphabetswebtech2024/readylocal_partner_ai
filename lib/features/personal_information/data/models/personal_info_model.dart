import '../../../../core/models/User.dart';
import '../../domain/entities/personal_info_entity.dart';

class PersonalInfoModel extends PersonalInfoEntity {
  const PersonalInfoModel({
    required super.user,
    required super.isSuccess,
  });

  factory PersonalInfoModel.fromJson(Map<String, dynamic> json) {
    final rawUser = json['Data'] ?? json['data'] ?? json;
    final user = User.fromJson(rawUser is Map<String, dynamic> ? rawUser : <String, dynamic>{});
    return PersonalInfoModel(
      user: user,
      isSuccess: json['Status'] == 'SUCCESS',
    );
  }
}
