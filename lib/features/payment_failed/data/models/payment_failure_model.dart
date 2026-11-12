import '../../domain/entities/payment_failure_entity.dart';

class PaymentFailureModel extends PaymentFailureEntity {
  const PaymentFailureModel({
    super.title,
    super.subtitle,
  });

  factory PaymentFailureModel.fromJson(Map<String, dynamic> json) {
    return PaymentFailureModel(
      title: json['title'] as String? ?? 'Payment Failed',
      subtitle: json['subtitle'] as String? ?? 'Try after sometime.',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
    };
  }
}
