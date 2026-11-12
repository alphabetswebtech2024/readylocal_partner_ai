import '../../../../core/models/User.dart';
import '../../domain/entities/otp_auth_entity.dart';

class OtpAuthModel extends OtpAuthEntity {
  const OtpAuthModel({
    required super.user,
    required super.token,
    required super.isProfileComplete,
  });

  factory OtpAuthModel.fromJson(Map<String, dynamic> json) {
    final rawUser = json['UserData'] ??
        json['Data'] ??
        json['data'] ??
        json['user'] ??
        json['User'] ??
        json;

    final Map<String, dynamic> userMap = rawUser is Map<String, dynamic>
        ? (rawUser.containsKey('UserData')
            ? (rawUser['UserData'] as Map<String, dynamic>)
            : rawUser)
        : <String, dynamic>{};

    final user = User.fromJson(json.containsKey('UserData') ? json : userMap);

    final token = (json['token'] ??
            json['Token'] ??
            json['jwtToken'] ??
            json['JWTToken'] ??
            userMap['token'] ??
            userMap['Token'] ??
            '')
        .toString();

    final bool isProfileUpdated = user.isProfileUpdated ||
        (json['UserData']?['isProfileUpdated'] as bool? ?? false) ||
        (json['isProfileUpdated'] as bool? ?? false);

    final bool isComplete = isProfileUpdated &&
        (user.FirstName.trim().isNotEmpty || user.LastName.trim().isNotEmpty);

    return OtpAuthModel(
      user: user,
      token: token,
      isProfileComplete: isComplete,
    );
  }
}
