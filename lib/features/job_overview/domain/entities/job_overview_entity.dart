class JobOverviewEntity {
  final String customerId;
  final String id;
  final String serviceId;
  final String title;
  final double amount;
  final String dateTime;
  final bool isInstant;
  final String etaLabel;
  final List<String> aboutPoints;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String distance;
  final String address;
  final String? imageUrl;
  final String status;
  final double latitude;
  final double longitude;
  final Map<String, dynamic> rawApiData;
  final String nextStep;
  final int? sentTimeMs;

  const JobOverviewEntity({
    required this.customerId,
    required this.id,
    required this.serviceId,
    required this.title,
    required this.amount,
    required this.dateTime,
    required this.isInstant,
    required this.etaLabel,
    required this.aboutPoints,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.distance,
    required this.address,
    this.imageUrl,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.rawApiData,
    required this.nextStep,
    this.sentTimeMs,
  });
}
