import '../../../../core/models/User.dart';

class PersonalInfoEntity {
  final User user;
  final bool isSuccess;

  const PersonalInfoEntity({
    required this.user,
    required this.isSuccess,
  });
}
