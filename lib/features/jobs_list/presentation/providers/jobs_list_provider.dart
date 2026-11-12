import 'package:flutter/foundation.dart';
import '../../../../core/models/User.dart';
import '../../../../core/provider/UserProvider.dart';
import '../../domain/entities/job_item_entity.dart';
import '../../domain/usecases/get_jobs_list_usecase.dart';

class JobsListProvider extends ChangeNotifier {
  final GetJobsListUseCase getJobsListUseCase;

  JobsListProvider({required this.getJobsListUseCase});

  bool _isLoading = false;
  String? _errorMessage;
  List<JobItemEntity> _allJobs = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<JobItemEntity> get ongoingJobs =>
      _allJobs.where((j) => j.status != 'Completed' && j.status != 'Cancelled').toList();

  List<JobItemEntity> get completedJobs =>
      _allJobs.where((j) => j.status == 'Completed').toList();

  Future<void> fetchJobs() async {
    final user = await UserProvider.getCurrentUser();
    if (user == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getJobsListUseCase(user.id);
    result.when(
      success: (jobs) {
        _allJobs = jobs;
        _isLoading = false;
        notifyListeners();
      },
      failure: (message) {
        _errorMessage = message;
        _isLoading = false;
        notifyListeners();
      },
    );
  }
}
