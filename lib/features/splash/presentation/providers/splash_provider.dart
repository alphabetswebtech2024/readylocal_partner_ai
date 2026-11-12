import 'package:flutter/foundation.dart';
import '../../domain/entities/splash_partner_status_entity.dart';
import '../../domain/usecases/check_partner_status_usecase.dart';

class SplashProvider extends ChangeNotifier {
  final CheckPartnerStatusUseCase checkPartnerStatusUseCase;

  SplashProvider({required this.checkPartnerStatusUseCase});

  bool _isLoading = false;
  bool _disposed = false;

  // The status request may outlive the splash screen.
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  bool get isLoading => _isLoading;

  SplashPartnerStatusEntity? _statusEntity;
  SplashPartnerStatusEntity? get statusEntity => _statusEntity;

  Future<SplashPartnerStatusEntity?> verifyStatus(String partnerId) async {
    _isLoading = true;
    notifyListeners();

    final result = await checkPartnerStatusUseCase(partnerId);
    _statusEntity = result.dataOrNull;
    _isLoading = false;
    if (!_disposed) notifyListeners();
    return _statusEntity;
  }
}
