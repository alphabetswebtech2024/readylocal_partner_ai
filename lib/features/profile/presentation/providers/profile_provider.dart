import 'package:flutter/foundation.dart';

import '../../../../core/models/User.dart';
import '../../../../core/provider/UserProvider.dart';
import '../../domain/entities/partner_profile_data_entity.dart';
import '../../domain/usecases/get_partner_profile_usecase.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';

typedef ProfileController = ProfileProvider;

class ProfileProvider extends ChangeNotifier {
  final GetPartnerProfileUseCase getPartnerProfileUseCase;

  ProfileProvider({required this.getPartnerProfileUseCase});

  bool _isLoading = false;
  String? _errorMessage;
  User? _user;
  PartnerProfileDataEntity? _profileData;
  double _profileCompletion = 1.0;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get user => _user;
  PartnerProfileDataEntity? get profileData => _profileData;
  double get profileCompletion => _profileCompletion;

  String get displayName {
    if (_user == null) return '';
    final name = '${_user!.FirstName} ${_user!.LastName}'.trim();
    return name.isEmpty ? L10n.current.partnerFallback : name;
  }

  String get displayRole {
    if (_user == null || _user!.phone.isEmpty) return '';
    return _user!.phone.toString().contains('+')
        ? _user!.phone.toString()
        : '+${_user!.phone.toString()}';
  }

  double _calculateCompletion(User? user) {
    if (user == null) return 0.0;
    final fields = [
      user.FirstName.isNotEmpty,
      user.LastName.isNotEmpty,
      user.phone.isNotEmpty,
      user.email.isNotEmpty,
      user.Address.isNotEmpty,
      user.City.isNotEmpty,
      user.Avatar.isNotEmpty,
      user.UPI.isNotEmpty,
      user.AadharPicFront.isNotEmpty,
      user.PanPics.isNotEmpty,
    ];
    final filled = fields.where((f) => f).length;
    return filled / fields.length;
  }

  Future<void> loadUserProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await UserProvider.getCurrentUser();
      _profileCompletion = _calculateCompletion(_user);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDetailedProfile() async {
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

      final result = await getPartnerProfileUseCase(_user!.id);
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

  Future<void> logout() async {
    await UserProvider.removeCurrentUser();
    _user = null;
    _profileData = null;
    notifyListeners();
  }
}
