import 'package:flutter/foundation.dart';
import '../../../../core/models/User.dart';
import '../../../../core/provider/UserProvider.dart';
import '../../domain/entities/view_profile_entity.dart';
import '../../domain/usecases/get_view_profile_usecase.dart';

class ViewProfileProvider extends ChangeNotifier {
  final GetViewProfileUseCase getViewProfileUseCase;

  ViewProfileProvider({required this.getViewProfileUseCase});

  bool _isLoading = false;
  String? _errorMessage;
  User? _user;
  ViewProfileEntity? _profileData;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get user => _user;
  ViewProfileEntity? get profileData => _profileData;

  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await UserProvider.getCurrentUser();
      if (_user == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final result = await getViewProfileUseCase(_user!.id);
      result.when(
        success: (data) {
          _profileData = data;
          _isLoading = false;
          notifyListeners();
        },
        failure: (message) {
          _errorMessage = message;
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
