import '../../domain/entities/payment_success_entity.dart';

class PaymentSuccessModel extends PaymentSuccessEntity {
  const PaymentSuccessModel({
    required super.isSynced,
  });

  factory PaymentSuccessModel.create({required bool isSynced}) {
    return PaymentSuccessModel(isSynced: isSynced);
  }
}
