import '../../domain/entities/login_result_entity.dart';

class LoginResultModel extends LoginResultEntity {
  const LoginResultModel({
    required super.isSuccess,
    required super.message,
  });

  factory LoginResultModel.fromJson(Map<String, dynamic> json) {
    return LoginResultModel(
      isSuccess: json['Status'] == 'SUCCESS',
      message: (json['ResponseMsg'] ?? json['message'] ?? 'OTP sent successfully').toString(),
    );
  }
}
