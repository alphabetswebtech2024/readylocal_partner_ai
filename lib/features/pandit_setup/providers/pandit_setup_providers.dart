import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../../core/di/service_locator.dart';
import '../presentation/providers/pandit_setup_provider.dart';

List<SingleChildWidget> panditSetupProviders = [
  ChangeNotifierProvider<PanditSetupProvider>(
    create: (_) => ServiceLocator.createPanditSetupProvider(),
  ),
];
