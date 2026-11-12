import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/services/job_closed.dart';
import '../../../../core/services/job_ring.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../domain/entities/notification_popup_config.dart';
import '../../../job_overview/presentation/screens/job_overview_screen.dart';

class NotificationPopupController extends ChangeNotifier {
  bool _visible = false;
  PopupStep _step = PopupStep.jobDetail;
  PopupConfig? _config;
  bool _isSubmitting = false;
  final TextEditingController rejectReasonController = TextEditingController();

  Timer? _autoCloseTimer;
  int? _sentTimeMs;
  DateTime? _fallbackDeadline;
  int _timeLeft = kJobRequestWindowSeconds;

  /// Closes this popup when the server says another partner took the job.
  late final StreamSubscription<String> _closedSub = JobClosed.stream.listen((id) {
    if (_visible && _config?.requestId == id && !_isSubmitting) {
      AppSnackBar.error(L10n.current.jobTakenByOther, title: L10n.current.warningTitle);
      close();
    }
  });

  bool get visible => _visible;
  PopupStep get step => _step;
  PopupConfig? get config => _config;
  bool get isSubmitting => _isSubmitting;
  int get timeLeft => _timeLeft;

  int _computeSecondsLeft() {
    if (_sentTimeMs != null) return jobSecondsLeft(_sentTimeMs);
    final ms = _fallbackDeadline!.difference(DateTime.now()).inMilliseconds;
    return (ms / 1000).ceil();
  }

  void open(PopupConfig config) {
    _closedSub; // start listening
    if (JobClosed.isClosed(config.requestId)) {
      AppSnackBar.error(L10n.current.jobTakenByOther, title: L10n.current.warningTitle);
      return;
    }
    _config = config;
    _step = PopupStep.jobDetail;
    _visible = true;
    _isSubmitting = false;
    rejectReasonController.clear();

    _sentTimeMs = parseSentTimeMs(config.apiData?['sentTime']);
    if (_sentTimeMs == null) {
      _fallbackDeadline = DateTime.now().add(const Duration(seconds: kJobRequestWindowSeconds));
    }
    _timeLeft = _computeSecondsLeft();

    _autoCloseTimer?.cancel();

    if (_timeLeft <= 0) {
      showJobExpiredToast();
      close();
      return;
    }

    _startRing();
    notifyListeners();

    _autoCloseTimer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      if (!_visible) {
        timer.cancel();
        return;
      }
      if (_isSubmitting) return;

      final left = _computeSecondsLeft();
      if (left <= 0) {
        timer.cancel();
        showJobExpiredToast();
        close();
      } else if (left != _timeLeft) {
        _timeLeft = left;
        notifyListeners();
      }
    });
  }

  void updateApiData(Map<String, dynamic> apiData) {
    if (_config == null || !_visible) return;
    _config = _config!.copyWith(apiData: apiData);
    notifyListeners();
  }

  void goTo(PopupStep step) {
    _step = step;
    // Rings on the job details; stops once the partner starts to answer.
    step == PopupStep.jobDetail ? _startRing() : _stopRing();
    notifyListeners();
  }

  bool _ringing = false;

  void _startRing() {
    if (_ringing) return;
    _ringing = true;
    JobRing.popupOpened();
  }

  void _stopRing() {
    if (!_ringing) return;
    _ringing = false;
    JobRing.popupFinished();
  }

  void goToConfirmAccept() => goTo(PopupStep.confirmAccept);
  void goToConfirmReject() => goTo(PopupStep.confirmReject);
  void goToRejectReason() => goTo(PopupStep.rejectReason);
  void backToJobDetail() => goTo(PopupStep.jobDetail);

  void setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }

  void close() {
    _autoCloseTimer?.cancel();
    _stopRing();
    _visible = false;
    _config = null;
    _isSubmitting = false;
    _step = PopupStep.jobDetail;
    rejectReasonController.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _closedSub.cancel();
    _autoCloseTimer?.cancel();
    _stopRing();
    rejectReasonController.dispose();
    super.dispose();
  }
}
