class JobItemEntity {
  final String jobId;
  final String requestId;
  final String serviceId;
  final String title;
  final double amount;
  final String dateTime;
  final double distanceKm;
  final String status;
  final String nextStep;

  const JobItemEntity({
    required this.jobId,
    required this.requestId,
    required this.serviceId,
    required this.title,
    required this.amount,
    required this.dateTime,
    required this.distanceKm,
    required this.status,
    required this.nextStep,
  });
}
