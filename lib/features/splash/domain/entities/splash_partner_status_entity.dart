class SplashPartnerStatusEntity {
  final bool hasPaid;
  final String registrationStatus;
  final String transactionId;

  const SplashPartnerStatusEntity({
    required this.hasPaid,
    required this.registrationStatus,
    required this.transactionId,
  });
}
