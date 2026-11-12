import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../../core/di/service_locator.dart';
import '../presentation/providers/login_provider.dart';

List<SingleChildWidget> loginProviders = [
  ChangeNotifierProvider<LoginProvider>(
    create: (_) => ServiceLocator.createLoginProvider(),
  ),
];
