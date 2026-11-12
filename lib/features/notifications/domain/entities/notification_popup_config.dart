enum PopupStep { jobDetail, confirmAccept, confirmReject, rejectReason }

class PopupConfig {
  final String requestId;
  final String customerName;
  final String fullAddress;
  final String formattedDate;
  final String timeSlot;
  final String status;
  final String mobile;
  final String paymentStatus;
  final List<Map<String, dynamic>> services;
  final Map<String, dynamic> pricing;
  final Map<String, dynamic>? apiData;

  const PopupConfig({
    required this.requestId,
    required this.customerName,
    required this.fullAddress,
    required this.formattedDate,
    required this.timeSlot,
    required this.status,
    required this.mobile,
    required this.paymentStatus,
    required this.services,
    required this.pricing,
    this.apiData,
  });

  PopupConfig copyWith({
    String? requestId,
    String? customerName,
    String? fullAddress,
    String? formattedDate,
    String? timeSlot,
    String? status,
    String? mobile,
    String? paymentStatus,
    List<Map<String, dynamic>>? services,
    Map<String, dynamic>? pricing,
    Map<String, dynamic>? apiData,
  }) {
    return PopupConfig(
      requestId: requestId ?? this.requestId,
      customerName: customerName ?? this.customerName,
      fullAddress: fullAddress ?? this.fullAddress,
      formattedDate: formattedDate ?? this.formattedDate,
      timeSlot: timeSlot ?? this.timeSlot,
      status: status ?? this.status,
      mobile: mobile ?? this.mobile,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      services: services ?? this.services,
      pricing: pricing ?? this.pricing,
      apiData: apiData ?? this.apiData,
    );
  }
}
