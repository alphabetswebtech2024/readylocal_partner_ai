enum JobProgressStep { step1, step2 }

class JobProgressEntity {
  final String jobId;
  final JobProgressStep currentStep;
  final String? customerAvailability;

  const JobProgressEntity({
    required this.jobId,
    this.currentStep = JobProgressStep.step1,
    this.customerAvailability,
  });
}
