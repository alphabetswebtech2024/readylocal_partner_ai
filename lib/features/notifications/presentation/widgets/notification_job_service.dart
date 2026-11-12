import 'package:gotask_partner/core/services/job_closed.dart';
import 'package:gotask_partner/core/services/job_ring.dart';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/session/app_session.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../customer_details/data/models/customer_details_model.dart';
import '../../../job_overview/data/models/job_overview_model.dart';
import '../../../job_overview/presentation/screens/job_overview_screen.dart';
import '../../domain/entities/notification_popup_config.dart';
import '../providers/notification_popup_controller.dart';
import 'notification_popup_widget.dart';
import 'package:gotask_partner/core/design/app_colors.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';

class NotificationJobService {
  NotificationJobService._();

  static Future<Map<String, dynamic>?> getRequestDetailsMethod(
    String requestId, [
    String serviceId = '',
  ]) async {
    final result = await ServiceLocator.getJobRequestDetailsUseCase(requestId, serviceId);
    return result.dataOrNull;
  }

  static BuildContext? _loadingContext;
  static BuildContext? _errorDialogContext;
  static BuildContext? _popupContext;

  /// Jobs being shown, by request, so the same job is never shown twice (for
  /// example the push and a tap on its alert).
  static final Map<String, DateTime> _recentRequests = {};
  static Future<void> _queue = Future<void>.value();

  /// Pushes are handled one at a time. Two arriving together used to share one
  /// loading dialog, and the first could stay on screen for good.
  static void showJobPopupFromNotification(Map<String, dynamic> fcmData) {
    final id = fcmData['RequestID']?.toString() ?? '';
    final now = DateTime.now();
    // Same job pushed again while it is still open: show it once.
    _recentRequests.removeWhere((_, at) => now.difference(at) > const Duration(seconds: kJobRequestWindowSeconds));
    if (id.isNotEmpty) {
      if (_recentRequests.containsKey(id)) return;
      _recentRequests[id] = now;
    }
    _queue = _queue.then((_) => _show(fcmData)).catchError((Object e) {
      developer.log('Job popup error: $e');
      JobRing.noPopup();
    });
  }

  static Future<void> _show(Map<String, dynamic> fcmData) async {
    developer.log("Triggering showJobPopupFromNotification with data: $fcmData");

    final sentTimeMs = parseSentTimeMs(fcmData['sentTime']);
    if (sentTimeMs != null && jobSecondsLeft(sentTimeMs) <= 0) {
      developer.log("Job request expired. Age: ${DateTime.now().millisecondsSinceEpoch - sentTimeMs} ms");
      showJobExpiredToast();
      JobRing.noPopup();
      return;
    }

    final context = AppSession.navigatorKey.currentContext;

    if (context == null) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return _show(fcmData);
    }

    final requestId = fcmData['RequestID']?.toString();
    final serviceId = fcmData['ServiceID']?.toString();

    // Another partner took it before it could be shown.
    if (JobClosed.isClosed(requestId)) {
      JobRing.noPopup();
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (ctx) {
        _loadingContext = ctx;
        return const LoadingPopup();
      },
    );

    Map<String, dynamic>? apiData;
    if (requestId != null && requestId.isNotEmpty) {
      apiData = await getRequestDetailsMethod(requestId, serviceId ?? '');
    }

    if (_loadingContext != null && _loadingContext!.mounted) {
      Navigator.of(_loadingContext!).pop();
      _loadingContext = null;
    }

    final activeContext = AppSession.navigatorKey.currentContext;
    if (activeContext == null || !activeContext.mounted || JobClosed.isClosed(requestId)) {
      JobRing.noPopup();
      return;
    }

    if (apiData != null && apiData.isNotEmpty) {
      final String status = apiData['Status']?.toString().toUpperCase() ?? '';
      if (status == 'CANCELLED') {
        JobRing.noPopup();
        _showJobCancelledDialog(activeContext);
        return;
      }
    }

    _displayJobPopup(activeContext, fcmData, apiData);
  }

  static void _showJobCancelledDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        _errorDialogContext = ctx;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(L10n.current.jobCancelledTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(L10n.current.jobCancelledMessage),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (_errorDialogContext != null && _errorDialogContext!.mounted) {
                  Navigator.of(_errorDialogContext!).pop();
                  _errorDialogContext = null;
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPressed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(L10n.current.commonOk, style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  static void _displayJobPopup(
    BuildContext context,
    Map<String, dynamic> fcmData,
    Map<String, dynamic>? apiData,
  ) {
    final customerName = apiData?['CustomerName'] ?? fcmData['CustomerName'] ?? L10n.current.jobCustomer;
    final address = apiData?['SourceAddress'] ?? fcmData['Address'] ?? L10n.current.noAddressProvided;
    final reqDate = apiData?['AppointmentDate'] ?? fcmData['RequestDate'] ?? '';
    final reqTime = apiData?['AppointmentTime'] ?? fcmData['Time'] ?? '';

    String formatDate(String raw) {
      try {
        final dt = DateTime.parse(raw);
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
      } catch (_) {
        return raw;
      }
    }

    final config = PopupConfig(
      requestId: apiData?['_id'] ?? fcmData['RequestID'] ?? '',
      customerName: customerName,
      fullAddress: apiData?['PinCode'] != null ? '$address - ${apiData!['PinCode']}' : address,
      formattedDate: reqDate.length > 12 ? formatDate(reqDate) : reqDate,
      timeSlot: reqTime,
      status: apiData?['Status'] ?? '',
      mobile: apiData?['MobileNumber']?.toString() ?? '',
      paymentStatus: apiData?['Payment']?['Status'] ?? '',
      services: apiData != null && apiData['Services'] != null
          ? List<Map<String, dynamic>>.from(apiData['Services'])
          : [
              {
                'Name': fcmData['ServiceName'] ?? L10n.current.jobServiceRequest,
                'EstimatedPrice': fcmData['Price'] ?? 0,
              }
            ],
      pricing: apiData != null && apiData['Pricing'] != null
          ? Map<String, dynamic>.from(apiData['Pricing'])
          : {'totalAmount': fcmData['Price'], 'finalAmount': fcmData['Price']},
      apiData: {
        ...?apiData,
        'Distance': fcmData['Distance'],
        'Image': fcmData['Image'],
        'CustomerProfileImage': fcmData['CustomerProfileImage'],
        'sentTime': fcmData['sentTime'],
      },
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (ctx) {
        _popupContext = ctx;
        return JobPopupControllerWrapper(
          config: config,
          onCloseDialog: () {
            if (_popupContext != null && _popupContext!.mounted) {
              _popupContext = null;
            }
          },
        );
      },
    );
  }
}

class JobPopupControllerWrapper extends StatefulWidget {
  final PopupConfig config;
  final VoidCallback? onCloseDialog;
  const JobPopupControllerWrapper({super.key, required this.config, this.onCloseDialog});
  @override
  State<JobPopupControllerWrapper> createState() => _JobPopupControllerWrapperState();
}

class _JobPopupControllerWrapperState extends State<JobPopupControllerWrapper> {
  late NotificationPopupController _controller;

  @override
  void initState() {
    super.initState();
    _controller = NotificationPopupController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.open(widget.config);
    });
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (!_controller.visible && mounted) {
      widget.onCloseDialog?.call();
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleAccept() async {
    _controller.setSubmitting(true);
    final jobId = widget.config.apiData?['JobId'] ?? widget.config.requestId;
    final serviceId = widget.config.apiData?['ServiceId'] ??
        (widget.config.services.isNotEmpty ? widget.config.services.first['_id'] ?? '' : '');

    try {
      final result = await ServiceLocator.acceptJobUseCase(
        partnerId: AppSession.userId,
        jobId: jobId,
        serviceId: serviceId,
      );

      if (mounted) {
        _controller.close();
        result.when(
          success: (_) {
            final mappedJobData = JobOverviewData.fromApi(widget.config.apiData, widget.config.apiData ?? {});
            final customerDetails = CustomerDetails.fromJobOverview(mappedJobData, widget.config.apiData ?? {});
            final navCtx = AppSession.context;
            if (navCtx != null) {
              navCtx.push(AppRoutes.customerDetails, extra: customerDetails);
            }
            AppSnackBar.success(L10n.current.jobAcceptedSuccess);
          },
          failure: (msg) {
            AppSnackBar.error(msg);
          },
        );
      }
    } catch (e) {
      if (mounted) {
        _controller.close();
        AppSnackBar.error(L10n.current.networkError);
      }
    }
  }

  Future<void> _handleReject() async {
    final reason = _controller.rejectReasonController.text.trim();
    if (reason.isEmpty) {
      AppSnackBar.error(L10n.current.enterRejectionReason);
      return;
    }

    _controller.setSubmitting(true);
    final jobId = widget.config.apiData?['JobId'] ?? widget.config.requestId;

    try {
      final result = await ServiceLocator.rejectJobUseCase(
        partnerId: AppSession.userId,
        jobId: jobId,
        reason: reason,
      );

      if (mounted) {
        _controller.close();
        result.when(
          success: (_) {
            AppSnackBar.info(L10n.current.jobRejected);
          },
          failure: (msg) {
            AppSnackBar.error(msg);
          },
        );
      }
    } catch (e) {
      if (mounted) {
        _controller.close();
        AppSnackBar.error(L10n.current.networkError);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: NotificationPopup(
        controller: _controller,
        onAcceptConfirmed: _handleAccept,
        onRejectReasonSubmitted: _handleReject,
      ),
    );
  }
}

class LoadingPopup extends StatelessWidget {
  const LoadingPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryPressed), strokeWidth: 3),
            const SizedBox(height: 16),
            Text(
              L10n.current.loadingJobDetails,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

Future<Map<String, dynamic>?> getRequestDetailsMethod(String requestId, [String serviceId = '']) =>
    NotificationJobService.getRequestDetailsMethod(requestId, serviceId);

void showJobPopupFromNotification(Map<String, dynamic> fcmData) =>
    NotificationJobService.showJobPopupFromNotification(fcmData);
