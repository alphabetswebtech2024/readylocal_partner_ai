import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/payment_failure_entity.dart';
import '../../domain/usecases/get_payment_failure_details_usecase.dart';

class PaymentFailedProvider extends ChangeNotifier {
  final GetPaymentFailureDetailsUseCase getPaymentFailureDetailsUseCase;

  PaymentFailureEntity? _failureEntity;
  Timer? _dismissTimer;
  bool _shouldDismiss = false;

  PaymentFailedProvider({required this.getPaymentFailureDetailsUseCase}) {
    _init();
  }

  PaymentFailureEntity get failureEntity =>
      _failureEntity ?? const PaymentFailureEntity();
  bool get shouldDismiss => _shouldDismiss;

  void _init() {
    _failureEntity = getPaymentFailureDetailsUseCase();
    _startDismissTimer();
  }

  void _startDismissTimer() {
    _dismissTimer?.cancel();
    _dismissTimer = Timer(const Duration(seconds: 7), () {
      _shouldDismiss = true;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }
}
