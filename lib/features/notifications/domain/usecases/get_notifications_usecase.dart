import '../../../../core/network/api_result.dart';
import '../entities/app_notification_entity.dart';
import '../repositories/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository repository;

  GetNotificationsUseCase(this.repository);

  Future<ApiResult<List<AppNotificationEntity>>> call() {
    return repository.getNotifications();
  }
}
