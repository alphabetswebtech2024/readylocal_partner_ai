import 'package:flutter/foundation.dart';
import '../../domain/usecases/accept_job_usecase.dart';
import '../../domain/usecases/reject_job_usecase.dart';

typedef JobOverviewController = JobOverviewProvider;

class JobOverviewProvider extends ChangeNotifier {
  final AcceptJobUseCase acceptJobUseCase;
  final RejectJobUseCase rejectJobUseCase;

  JobOverviewProvider({
    required this.acceptJobUseCase,
    required this.rejectJobUseCase,
  });

  bool _isAccepting = false;
  bool _isRejecting = false;
  String? _errorMessage;

  bool get isAccepting => _isAccepting;
  bool get isRejecting => _isRejecting;
  String? get errorMessage => _errorMessage;

  Future<bool> acceptJob({
    required String partnerId,
    required String jobId,
    required String serviceId,
  }) async {
    _isAccepting = true;
    _errorMessage = null;
    notifyListeners();

    final result = await acceptJobUseCase(
      partnerId: partnerId,
      jobId: jobId,
      serviceId: serviceId,
    );

    bool isSuccess = false;
    result.when(
      success: (_) {
        _isAccepting = false;
        isSuccess = true;
        notifyListeners();
      },
      failure: (message) {
        _errorMessage = message;
        _isAccepting = false;
        isSuccess = false;
        notifyListeners();
      },
    );

    return isSuccess;
  }

  Future<bool> rejectJob({
    required String partnerId,
    required String jobId,
    required String reason,
  }) async {
    _isRejecting = true;
    _errorMessage = null;
    notifyListeners();

    final result = await rejectJobUseCase(
      partnerId: partnerId,
      jobId: jobId,
      reason: reason,
    );

    bool isSuccess = false;
    result.when(
      success: (_) {
        _isRejecting = false;
        isSuccess = true;
        notifyListeners();
      },
      failure: (message) {
        _errorMessage = message;
        _isRejecting = false;
        isSuccess = false;
        notifyListeners();
      },
    );

    return isSuccess;
  }
}
