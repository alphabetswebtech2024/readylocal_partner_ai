import 'package:flutter/foundation.dart';
import '../../../../core/models/User.dart';
import '../../../../core/provider/UserProvider.dart';
import '../../domain/usecases/save_personal_info_usecase.dart';

class PersonalInformationProvider extends ChangeNotifier {
  final SavePersonalInfoUseCase savePersonalInfoUseCase;
  final UserProvider userProvider;

  PersonalInformationProvider({
    required this.savePersonalInfoUseCase,
    required this.userProvider,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> saveProfile(Map<String, dynamic> requestData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await savePersonalInfoUseCase(requestData);
    _isLoading = false;

    return result.when(
      success: (info) {
        if (info.user.id.isNotEmpty) userProvider.setUser(info.user);
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
