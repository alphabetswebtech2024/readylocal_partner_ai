import '../../domain/entities/customer_details_entity.dart';
import '../../../job_overview/domain/entities/job_overview_entity.dart';

class CustomerDetailsModel extends CustomerDetailsEntity {
  const CustomerDetailsModel({
    required super.jobId,
    required super.requestId,
    required super.serviceId,
    required super.customerId,
    required super.distance,
    required super.nextStep,
    required super.jobTitle,
    required super.jobAmount,
    required super.jobDateTime,
    required super.isInstant,
    required super.etaLabel,
    required super.aboutPoints,
    required super.customerName,
    required super.customerPhone,
    required super.customerEmail,
    required super.serviceBookedDate,
    required super.serviceBookedTime,
    required super.address,
    required super.latitude,
    required super.longitude,
    super.customerAvatarUrl,
  });

  factory CustomerDetailsModel.fromJobOverview(
    JobOverviewEntity job,
    Map<String, dynamic> apiData, {
    String? nextStep,
  }) {
    final parts = job.dateTime.split('|');

    String resolvedNextStep =
        (nextStep ?? apiData['NextStep']?.toString() ?? '').trim().toUpperCase();
    String reqStatus = (apiData['RequestStatus']?.toString() ??
            apiData['PartnerRequestStatus']?.toString() ??
            '')
        .trim()
        .toUpperCase();

    if (resolvedNextStep.isEmpty) {
      if (reqStatus == 'STARTED' ||
          reqStatus == 'IN PROGRESS' ||
          reqStatus == 'ONGOING') {
        resolvedNextStep = 'REACHED_CONFIRM';
      } else {
        resolvedNextStep = 'NAVIGATE_TO_LOCATION';
      }
    }

    return CustomerDetailsModel(
      jobId: apiData['JobId'] ?? apiData['JobID'] ?? job.id,
      requestId: apiData['RequestId'] ?? apiData['RequestID'] ?? job.id,
      serviceId: apiData['ServiceId'] ?? apiData['ServiceID'] ?? job.serviceId,
      customerId: apiData['CustomerId'] ?? apiData['CustomerID'] ?? '',
      distance: apiData['Distance']?.toString() ?? 'N/A',
      nextStep: resolvedNextStep,
      jobTitle: job.title,
      jobAmount: job.amount,
      jobDateTime: job.dateTime,
      isInstant: job.isInstant,
      etaLabel: job.etaLabel,
      aboutPoints: job.aboutPoints,
      customerName: job.customerName,
      customerPhone: job.customerPhone,
      customerEmail: job.customerEmail,
      serviceBookedDate: parts.isNotEmpty ? parts[0].trim() : '',
      serviceBookedTime: parts.length > 1 ? parts[1].trim() : '',
      address: job.address,
      latitude: job.latitude,
      longitude: job.longitude,
      customerAvatarUrl: job.imageUrl,
    );
  }
}

typedef CustomerDetails = CustomerDetailsModel;
