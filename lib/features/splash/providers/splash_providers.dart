import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../../core/di/service_locator.dart';
import '../presentation/providers/splash_provider.dart';

List<SingleChildWidget> splashProviders = [
  ChangeNotifierProvider<SplashProvider>(
    create: (_) => ServiceLocator.createSplashProvider(),
  ),
];
