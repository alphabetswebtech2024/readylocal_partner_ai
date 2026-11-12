import 'package:flutter/foundation.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/provider/UserProvider.dart';
import '../../domain/entities/otp_auth_entity.dart';
import '../../domain/usecases/resend_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';

class OtpVerificationProvider extends ChangeNotifier {
  final VerifyOtpUseCase verifyOtpUseCase;
  final ResendOtpUseCase resendOtpUseCase;
  final UserProvider userProvider;

  OtpVerificationProvider({
    required this.verifyOtpUseCase,
    required this.resendOtpUseCase,
    required this.userProvider,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  OtpAuthEntity? _authEntity;
  OtpAuthEntity? get authEntity => _authEntity;

  Future<bool> verifyOtp({
    required String mobileNumber,
    required String otp,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await verifyOtpUseCase(mobileNumber: mobileNumber, otp: otp);
    _isLoading = false;

    switch (result) {
      case ApiSuccess(:final data):
        _authEntity = data;
        await userProvider.setAsCurrentUser(data.user);
        notifyListeners();
        return true;
      case ApiFailure(:final message):
        _errorMessage = message;
        notifyListeners();
        return false;
    }
  }

  Future<bool> resendOtp(String mobileNumber) async {
    final result = await resendOtpUseCase(mobileNumber);
    switch (result) {
      case ApiSuccess(:final data):
        return data;
      case ApiFailure(:final message):
        _errorMessage = message;
        notifyListeners();
        return false;
    }
  }
}
