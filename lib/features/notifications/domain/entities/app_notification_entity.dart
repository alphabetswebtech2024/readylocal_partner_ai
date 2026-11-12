class AppNotificationEntity {
  final String id;
  final String title;
  final String subtitle;
  final String? jobTitle;
  final double? jobAmount;
  final String? jobDateTime;
  final String? partnerName;
  final String? partnerAvatar;
  final double? distanceKm;
  final String? jobImageUrl;
  final bool isJob;
  bool isRead;
  final Map<String, dynamic>? rawJobData;

  AppNotificationEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    this.jobTitle,
    this.jobAmount,
    this.jobDateTime,
    this.partnerName,
    this.partnerAvatar,
    this.distanceKm,
    this.jobImageUrl,
    this.isJob = false,
    this.isRead = false,
    this.rawJobData,
  });
}
