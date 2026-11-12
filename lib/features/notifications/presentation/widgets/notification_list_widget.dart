import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../domain/entities/app_notification_entity.dart';
import 'package:gotask_partner/core/design/app_colors.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';

typedef NotificationList = NotificationListWidget;

class NotificationListWidget extends StatelessWidget {
  final List<AppNotificationEntity> notifications;
  final void Function(AppNotificationEntity) onJobTap;

  const NotificationListWidget({
    super.key,
    required this.notifications,
    required this.onJobTap,
  });

  @override
  Widget build(BuildContext context) {
    final unread = notifications.where((n) => !n.isRead).toList();
    final read = notifications.where((n) => n.isRead).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (unread.isNotEmpty) ...[
          _sectionHeader(context.l10n.newNotification),
          const SizedBox(height: 12),
          ...unread.map((n) => NotificationCard(
                notification: n,
                onJobTap: onJobTap,
              )),
        ],
        if (read.isNotEmpty) ...[
          const SizedBox(height: 20),
          _sectionHeader(context.l10n.earlierLabel),
          const SizedBox(height: 12),
          ...read.map((n) => NotificationCard(
                notification: n,
                onJobTap: onJobTap,
              )),
        ],
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final AppNotificationEntity notification;
  final void Function(AppNotificationEntity) onJobTap;

  static const Color _green = AppColors.success;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onJobTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: notification.isJob ? () => onJobTap(notification) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/ic_green_tick.svg',
                  width: 24,
                  height: 24,
                  placeholderBuilder: (_) => const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: notification.isRead
                          ? FontWeight.w500
                          : FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (notification.isJob)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.textDisabled,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
