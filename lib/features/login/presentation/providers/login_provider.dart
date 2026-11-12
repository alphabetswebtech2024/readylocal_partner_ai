import 'package:flutter/foundation.dart';
import '../../domain/usecases/send_login_otp_usecase.dart';

class LoginProvider extends ChangeNotifier {
  final SendLoginOtpUseCase sendLoginOtpUseCase;

  LoginProvider({required this.sendLoginOtpUseCase});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> sendOtp(String mobileNumber) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await sendLoginOtpUseCase(mobileNumber);
    _isLoading = false;

    return result.when(
      success: (_) {
        notifyListeners();
        return true;
      },
      failure: (msg) {
        _errorMessage = msg;
        notifyListeners();
        return false;
      },
    );
  }
}
