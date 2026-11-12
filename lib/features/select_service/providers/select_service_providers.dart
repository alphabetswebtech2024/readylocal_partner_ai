import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../../core/di/service_locator.dart';
import '../presentation/providers/select_service_provider.dart';

List<SingleChildWidget> selectServiceProviders = [
  ChangeNotifierProvider<SelectServiceProvider>(
    create: (_) => ServiceLocator.createSelectServiceProvider(),
  ),
];
