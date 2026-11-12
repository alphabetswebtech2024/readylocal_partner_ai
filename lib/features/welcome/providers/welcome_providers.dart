import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../../core/di/service_locator.dart';
import '../presentation/providers/welcome_provider.dart';

List<SingleChildWidget> welcomeProviders = [
  ChangeNotifierProvider<WelcomeProvider>(create: (_) => ServiceLocator.createWelcomeProvider()),
];
