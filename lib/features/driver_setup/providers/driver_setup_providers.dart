import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../../core/di/service_locator.dart';
import '../presentation/providers/driver_setup_provider.dart';

List<SingleChildWidget> driverSetupProviders = [
  ChangeNotifierProvider<DriverSetupProvider>(
    create: (_) => ServiceLocator.createDriverSetupProvider(),
  ),
];
