import 'package:flutter/foundation.dart';
import '../../domain/usecases/sync_post_payment_usecase.dart';

class PaymentSuccessProvider extends ChangeNotifier {
  final SyncPostPaymentUseCase syncPostPaymentUseCase;

  PaymentSuccessProvider({required this.syncPostPaymentUseCase});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> onExploreApp({
    required String partnerId,
    required String deviceToken,
    required VoidCallback onComplete,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (deviceToken.isNotEmpty) {
        await syncPostPaymentUseCase(
          partnerId: partnerId,
          deviceToken: deviceToken,
        );
      }
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
      onComplete();
    }
  }
}
