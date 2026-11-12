import '../../domain/entities/job_progress_entity.dart';

class JobProgressModel extends JobProgressEntity {
  const JobProgressModel({
    required super.jobId,
    super.currentStep,
    super.customerAvailability,
  });
}
