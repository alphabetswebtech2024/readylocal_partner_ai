import '../../domain/entities/app_notification_entity.dart';

class NotificationModel extends AppNotificationEntity {
  NotificationModel({
    required super.id,
    required super.title,
    required super.subtitle,
    super.jobTitle,
    super.jobAmount,
    super.jobDateTime,
    super.partnerName,
    super.partnerAvatar,
    super.distanceKm,
    super.jobImageUrl,
    super.isJob,
    super.isRead,
    super.rawJobData,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? json['body']?.toString() ?? '',
      jobTitle: json['jobTitle']?.toString(),
      jobAmount: (json['jobAmount'] as num?)?.toDouble(),
      jobDateTime: json['jobDateTime']?.toString(),
      partnerName: json['partnerName']?.toString(),
      partnerAvatar: json['partnerAvatar']?.toString(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      jobImageUrl: json['jobImageUrl']?.toString(),
      isJob: json['isJob'] as bool? ?? false,
      isRead: json['isRead'] as bool? ?? false,
      rawJobData: json['rawJobData'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    if (jobTitle != null) 'jobTitle': jobTitle,
    if (jobAmount != null) 'jobAmount': jobAmount,
    if (jobDateTime != null) 'jobDateTime': jobDateTime,
    if (partnerName != null) 'partnerName': partnerName,
    if (partnerAvatar != null) 'partnerAvatar': partnerAvatar,
    if (distanceKm != null) 'distanceKm': distanceKm,
    if (jobImageUrl != null) 'jobImageUrl': jobImageUrl,
    'isJob': isJob,
    'isRead': isRead,
    if (rawJobData != null) 'rawJobData': rawJobData,
  };
}
