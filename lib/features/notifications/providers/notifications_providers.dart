import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../../core/di/service_locator.dart';
import '../presentation/providers/notifications_provider.dart';

List<SingleChildWidget> get notificationsProviders => [
  ChangeNotifierProvider<NotificationsProvider>(
    create: (_) => ServiceLocator.createNotificationsController(),
  ),
];
