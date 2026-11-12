import '../../domain/entities/job_overview_entity.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';

class JobOverviewModel extends JobOverviewEntity {
  const JobOverviewModel({
    required super.customerId,
    required super.id,
    required super.serviceId,
    required super.title,
    required super.amount,
    required super.dateTime,
    required super.isInstant,
    required super.etaLabel,
    required super.aboutPoints,
    required super.customerName,
    required super.customerPhone,
    required super.customerEmail,
    required super.distance,
    required super.address,
    super.imageUrl,
    required super.status,
    required super.latitude,
    required super.longitude,
    required super.rawApiData,
    required super.nextStep,
    super.sentTimeMs,
  });

  factory JobOverviewModel.fromApi(
    Map<String, dynamic>? apiData,
    Map<String, dynamic> fcmData, {
    String? nextStep,
  }) {
    final services = apiData?['Services'] as List? ?? [];
    final firstService = services.isNotEmpty ? services.first : null;

    final serviceName = [
      firstService?['Name'],
      apiData?['ServiceName'],
      fcmData['ServiceName']
    ]
        .map((e) => e?.toString().trim() ?? '')
        .firstWhere((e) => e.isNotEmpty, orElse: () => 'Service Request');

    final date = apiData?['AppointmentDate'] ?? fcmData['RequestDate'] ?? '';
    final time = apiData?['AppointmentTime'] ?? fcmData['Time'] ?? '';

    String formatDate(String raw) {
      try {
        final dt = DateTime.parse(raw);
        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
      } catch (_) {
        return raw;
      }
    }

    final formattedDate = date.length > 12 ? formatDate(date) : date;

    double lat = 0.0;
    double lng = 0.0;

    final loc =
        apiData?['SourceLocation'] ?? apiData?['Location'] ?? fcmData['Location'];

    if (loc != null && loc is Map && loc['coordinates'] != null) {
      final coords = loc['coordinates'] as List;
      if (coords.length >= 2) {
        lng = (coords[0] as num).toDouble();
        lat = (coords[1] as num).toDouble();
      }
    }

    final cId = apiData?['CustomerId'] ?? fcmData['CustomerID'] ?? '';
    final jId = apiData?['JobId'] ?? fcmData['RequestID'] ?? '';
    final sId = apiData?['ServiceId'] ??
        firstService?['ServiceID'] ??
        firstService?['_id'] ??
        '';

    final pricing = apiData?['Pricing'] as Map?;
    final finalAmount = apiData?['Amount'] ??
        pricing?['finalAmount'] ??
        pricing?['totalAmount'] ??
        fcmData['Price'] ??
        0;

    final dynamicDistance =
        apiData?['Distance']?.toString() ?? fcmData['Distance']?.toString() ?? 'N/A';

    final rawData = <String, dynamic>{};
    if (fcmData.isNotEmpty) rawData.addAll(fcmData);
    if (apiData != null) rawData.addAll(apiData);

    int? parseSentTime(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    return JobOverviewModel(
      customerId: cId.toString(),
      id: jId.toString(),
      serviceId: sId.toString(),
      title: serviceName,
      amount: double.tryParse(finalAmount.toString()) ?? 0.0,
      dateTime: '$formattedDate | $time',
      isInstant: false,
      etaLabel: fcmData['Time'] ?? '',
      aboutPoints: const [],
      customerName:
          apiData?['CustomerName'] ?? fcmData['CustomerName'] ?? L10n.current.jobCustomer,
      customerPhone: apiData?['MobileNumber']?.toString() ?? '',
      customerEmail: apiData?['CustomerEmail'] ?? '',
      distance: dynamicDistance,
      address:
          apiData?['SourceAddress'] ?? fcmData['Address'] ?? L10n.current.noAddressProvided,
      imageUrl: apiData?['ServiceImage']?.toString() ??
          fcmData['Image']?.toString() ??
          apiData?['Image']?.toString(),
      status: apiData?['RequestStatus'] ?? apiData?['Status'] ?? 'Pending',
      latitude: lat,
      longitude: lng,
      rawApiData: rawData,
      nextStep: nextStep ?? apiData?['NextStep'] ?? '',
      sentTimeMs: parseSentTime(fcmData['sentTime'] ?? apiData?['sentTime']),
    );
  }
}

typedef JobOverviewData = JobOverviewModel;
