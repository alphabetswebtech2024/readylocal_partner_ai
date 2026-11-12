import 'dart:developer' show log;
import 'package:flutter/foundation.dart';
import '../../domain/entities/app_notification_entity.dart';
import '../../domain/usecases/get_notifications_usecase.dart';

typedef NotificationsController = NotificationsProvider;

class NotificationsProvider extends ChangeNotifier {
  final GetNotificationsUseCase _getNotificationsUseCase;

  NotificationsProvider({
    required GetNotificationsUseCase getNotificationsUseCase,
  }) : _getNotificationsUseCase = getNotificationsUseCase;

  List<AppNotificationEntity> _notifications = [];
  bool _isLoading = false;

  List<AppNotificationEntity> get notifications => _notifications;
  bool get isLoading => _isLoading;

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    final result = await _getNotificationsUseCase();
    result.when(
      success: (data) => _notifications = data,
      failure: (message) => log('notifications: $message'),
    );

    _isLoading = false;
    notifyListeners();
  }

  void markAsRead(String id) {
    try {
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index].isRead = true;
        notifyListeners();
      }
    } catch (e) {
      log('notifications: $e');
    }
  }
}
