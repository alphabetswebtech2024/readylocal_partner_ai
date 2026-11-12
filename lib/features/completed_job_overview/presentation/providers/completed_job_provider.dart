import 'package:flutter/foundation.dart';
import '../../../job_overview/domain/entities/job_overview_entity.dart';
import '../../domain/entities/completed_job_entity.dart';
import '../../domain/usecases/get_completed_job_details_usecase.dart';

class CompletedJobProvider extends ChangeNotifier {
  final GetCompletedJobDetailsUseCase getCompletedJobDetailsUseCase;

  CompletedJobProvider({required this.getCompletedJobDetailsUseCase});

  CompletedJobEntity? _completedJob;
  CompletedJobEntity? get completedJob => _completedJob;

  void init(JobOverviewEntity job) {
    _completedJob = getCompletedJobDetailsUseCase(job);
    notifyListeners();
  }
}
