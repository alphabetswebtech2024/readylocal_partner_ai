import '../../domain/entities/splash_partner_status_entity.dart';

class SplashPartnerStatusModel extends SplashPartnerStatusEntity {
  const SplashPartnerStatusModel({
    required super.hasPaid,
    required super.registrationStatus,
    required super.transactionId,
  });

  factory SplashPartnerStatusModel.fromJson(Map<String, dynamic> json) {
    final status = (json['registrationStatus'] ?? '').toString().toUpperCase();
    final isPaid = status == 'PAID' || status == 'COMPLETED' || status == 'ACTIVE';
    final txnId = json['registrationFee'] is Map
        ? (json['registrationFee']['transactionId'] ?? 'PAID_ON_SERVER').toString()
        : 'PAID_ON_SERVER';

    return SplashPartnerStatusModel(
      hasPaid: isPaid,
      registrationStatus: status,
      transactionId: txnId,
    );
  }
}
