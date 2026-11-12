import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import '../../../core/di/service_locator.dart';
import '../presentation/providers/app_web_view_provider.dart';

List<SingleChildWidget> appWebViewProviders = [
  ChangeNotifierProvider<AppWebViewProvider>(
    create: (_) => ServiceLocator.createAppWebViewProvider(),
  ),
];
