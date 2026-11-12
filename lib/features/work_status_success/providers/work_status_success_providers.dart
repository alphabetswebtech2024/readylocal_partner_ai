import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../../core/di/service_locator.dart';
import '../presentation/providers/work_status_success_provider.dart';

List<SingleChildWidget> get workStatusSuccessProviders => [
  ChangeNotifierProvider<WorkStatusSuccessProvider>(
    create: (_) => ServiceLocator.createWorkStatusSuccessProvider(),
  ),
];
