class CustomerDetailsEntity {
  final String jobId;
  final String requestId;
  final String serviceId;
  final String customerId;
  final String distance;
  final String nextStep;
  final String jobTitle;
  final double jobAmount;
  final String jobDateTime;
  final bool isInstant;
  final String etaLabel;
  final List<String> aboutPoints;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String serviceBookedDate;
  final String serviceBookedTime;
  final String address;
  final double latitude;
  final double longitude;
  final String? customerAvatarUrl;

  const CustomerDetailsEntity({
    required this.jobId,
    required this.requestId,
    required this.serviceId,
    required this.customerId,
    required this.distance,
    required this.nextStep,
    required this.jobTitle,
    required this.jobAmount,
    required this.jobDateTime,
    required this.isInstant,
    required this.etaLabel,
    required this.aboutPoints,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.serviceBookedDate,
    required this.serviceBookedTime,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.customerAvatarUrl,
  });
}
