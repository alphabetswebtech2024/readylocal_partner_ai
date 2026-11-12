import '../../domain/entities/job_item_entity.dart';

class JobItemModel extends JobItemEntity {
  const JobItemModel({
    required super.jobId,
    required super.requestId,
    required super.serviceId,
    required super.title,
    required super.amount,
    required super.dateTime,
    required super.distanceKm,
    required super.status,
    required super.nextStep,
  });

  factory JobItemModel.fromJson(Map<String, dynamic> json) {
    return JobItemModel(
      jobId: json['JobID']?.toString() ?? '',
      requestId: json['RequestID']?.toString() ?? '',
      serviceId: json['ServiceID']?.toString() ?? '',
      title: json['RequestType']?.toString() ?? 'Unknown Job',
      amount: (json['Amount'] as num?)?.toDouble() ?? 0.0,
      dateTime: '${json['ApointmentDate'] ?? ''} | ${json['AppointmentTime'] ?? ''}',
      distanceKm: (json['DistanceKm'] as num?)?.toDouble() ?? 0.0,
      status: json['PartnerRequestStatus']?.toString() ?? '',
      nextStep: json['NextStep']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'JobID': jobId,
        'RequestID': requestId,
        'ServiceID': serviceId,
        'RequestType': title,
        'Amount': amount,
        'PartnerRequestStatus': status,
        'NextStep': nextStep,
      };
}
