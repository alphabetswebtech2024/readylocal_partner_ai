import '../../../../core/models/User.dart';

class OtpAuthEntity {
  final User user;
  final String token;
  final bool isProfileComplete;

  const OtpAuthEntity({
    required this.user,
    required this.token,
    required this.isProfileComplete,
  });
}
