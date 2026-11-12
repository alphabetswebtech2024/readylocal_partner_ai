import '../../../../core/network/api_result.dart';
import '../entities/app_notification_entity.dart';

abstract class NotificationRepository {
  Future<ApiResult<List<AppNotificationEntity>>> getNotifications();
  Future<ApiResult<Map<String, dynamic>?>> getJobRequestDetails(
    String requestId, [
    String serviceId = '',
  ]);
}
