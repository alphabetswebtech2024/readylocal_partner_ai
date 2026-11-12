import 'package:flutter/material.dart';
import 'package:gotask_partner/core/design/app_top_bar.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/session/app_session.dart';
import '../../domain/entities/app_notification_entity.dart';
import '../../domain/entities/notification_popup_config.dart';
import '../providers/notification_popup_controller.dart';
import '../providers/notifications_provider.dart';
import '../widgets/notification_job_service.dart';
import '../widgets/notification_list_widget.dart';
import '../widgets/notification_popup_widget.dart';
import 'package:gotask_partner/core/design/app_colors.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';
import 'package:gotask_partner/core/design/app_widgets.dart';

class NotificationScreen extends StatefulWidget {
  final Map<String, dynamic>? autoOpenJobData;
  final Map<String, dynamic>? autoOpenApiData;

  const NotificationScreen({
    super.key,
    this.autoOpenJobData,
    this.autoOpenApiData,
  });

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  static const Color _green = AppColors.success;

  late final NotificationPopupController _popupController;
  late final NotificationsProvider _notificationsProvider;

  @override
  void initState() {
    super.initState();
    _popupController = NotificationPopupController();
    _notificationsProvider = ServiceLocator.createNotificationsController();
    _notificationsProvider.loadNotifications();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndOpenPendingPopup();
    });
  }

  @override
  void dispose() {
    _popupController.dispose();
    _notificationsProvider.dispose();
    super.dispose();
  }

  PopupConfig _createPopupConfig(
    Map<String, dynamic> fcmData,
    Map<String, dynamic>? apiData,
  ) {
    final customerName =
        apiData?['CustomerName'] ?? fcmData['CustomerName'] ?? context.l10n.jobCustomer;
    final address =
        apiData?['SourceAddress'] ?? fcmData['Address'] ?? context.l10n.noAddressProvided;
    final reqDate =
        apiData?['AppointmentDate'] ?? fcmData['RequestDate'] ?? '';
    final reqTime = apiData?['AppointmentTime'] ?? fcmData['Time'] ?? '';
    final status = apiData?['Status'] ?? '';

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

    return PopupConfig(
      requestId: apiData?['_id'] ?? fcmData['RequestID'] ?? '',
      customerName: customerName,
      fullAddress: apiData?['PinCode'] != null
          ? '$address - ${apiData!['PinCode']}'
          : address,
      formattedDate: reqDate.length > 12 ? formatDate(reqDate) : reqDate,
      timeSlot: reqTime,
      status: status,
      mobile: apiData?['MobileNumber']?.toString() ?? '',
      paymentStatus: apiData?['Payment']?['Status'] ?? '',
      services: apiData != null && apiData['Services'] != null
          ? List<Map<String, dynamic>>.from(apiData['Services'])
          : [
              {
                'Name': fcmData['ServiceName'] ?? context.l10n.jobServiceRequest,
                'EstimatedPrice': fcmData['Price'] ?? 0
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
      },
    );
  }

  void _checkAndOpenPendingPopup() {
    final data = widget.autoOpenJobData ?? pendingNotificationData;
    if (data == null) return;
    pendingNotificationData = null;

    final config = _createPopupConfig(data, widget.autoOpenApiData);
    _popupController.open(config);

    if (widget.autoOpenApiData == null) {
      _fetchAndUpdateApiData(data['RequestID'] as String?, data);
    }
  }

  void _onJobCardTapped(AppNotificationEntity notification) async {
    _notificationsProvider.markAsRead(notification.id);

    final fcmData = <String, dynamic>{
      'RequestID': notification.rawJobData?['RequestID'] ?? notification.id,
      'Address': '',
      'RequestDate': notification.jobDateTime ?? '',
      'Time': '',
      ...?notification.rawJobData,
    };

    final config = _createPopupConfig(fcmData, null);
    _popupController.open(config);

    final requestId = notification.rawJobData?['RequestID'] as String?;
    await _fetchAndUpdateApiData(requestId, fcmData);
  }

  Future<void> _fetchAndUpdateApiData(
    String? requestId,
    Map<String, dynamic> fcmData,
  ) async {
    if (requestId == null || requestId.isEmpty) return;

    final String serviceId = fcmData['ServiceID'] ?? '';
    final apiData = await NotificationJobService.getRequestDetailsMethod(
      requestId,
      serviceId,
    );
    if (apiData != null && _popupController.visible) {
      final updatedConfig = _createPopupConfig(fcmData, apiData);
      _popupController.open(updatedConfig);
    }
  }

  Future<void> _onAcceptConfirmed() async {
    final config = _popupController.config;
    if (config == null) return;

    _popupController.setSubmitting(true);

    final jobId = config.requestId;
    final serviceId = config.apiData?['ServiceID'] ??
        (config.services.isNotEmpty
            ? config.services.first['_id'] ?? ''
            : '');

    final result = await ServiceLocator.acceptJobUseCase(
      partnerId: AppSession.userId,
      jobId: jobId,
      serviceId: serviceId,
    );

    if (mounted) {
      _popupController.close();
      result.when(
        success: (_) => _showSnackBar(context.l10n.jobAcceptedSuccess, _green),
        failure: (msg) => _showSnackBar(msg, Colors.red.shade700),
      );
    }
  }

  Future<void> _onRejectReasonSubmitted() async {
    final reason = _popupController.rejectReasonController.text.trim();
    if (reason.isEmpty) {
      _showSnackBar(
          context.l10n.enterReasonBeforeSubmit, Colors.red.shade600);
      return;
    }

    final config = _popupController.config;
    if (config == null) return;

    _popupController.setSubmitting(true);
    final jobId = config.requestId;

    final result = await ServiceLocator.rejectJobUseCase(
      partnerId: AppSession.userId,
      jobId: jobId,
      reason: reason,
    );

    if (mounted) {
      _popupController.close();
      result.when(
        success: (_) => _showSnackBar(context.l10n.jobRejected, Colors.red.shade500),
        failure: (msg) => _showSnackBar(msg, Colors.red.shade700),
      );
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(title: context.l10n.notificationsTitle),
      body: Stack(
        children: [
          ListenableBuilder(
            listenable: _notificationsProvider,
            builder: (context, _) {
              if (_notificationsProvider.isLoading) {
                return const AppListSkeleton(count: 5, itemHeight: 72);
              }
              if (_notificationsProvider.notifications.isEmpty) {
                return Center(
                  child: AppEmptyState(
                    title: context.l10n.noNotifications,
                    message: context.l10n.noNotificationsHint,
                    icon: Icons.notifications_none_rounded,
                  ),
                );
              }
              return NotificationListWidget(
                notifications: _notificationsProvider.notifications,
                onJobTap: _onJobCardTapped,
              );
            },
          ),
          NotificationPopup(
            controller: _popupController,
            onAcceptConfirmed: _onAcceptConfirmed,
            onRejectReasonSubmitted: _onRejectReasonSubmitted,
          ),
        ],
      ),
    );
  }
}
