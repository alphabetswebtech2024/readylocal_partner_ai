import '../../../../core/network/api_result.dart';
import '../../domain/entities/app_notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;

  NotificationRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<List<AppNotificationEntity>>> getNotifications() async {
    try {
      final list = await _remoteDataSource.getNotifications();
      return ApiResult.success(list);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  @override
  Future<ApiResult<Map<String, dynamic>?>> getJobRequestDetails(
    String requestId, [
    String serviceId = '',
  ]) async {
    try {
      final details = await _remoteDataSource.getJobRequestDetails(
        requestId,
        serviceId,
      );
      return ApiResult.success(details);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }
}
