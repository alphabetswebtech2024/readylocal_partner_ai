import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import '../../../core/di/service_locator.dart';
import '../presentation/providers/home_provider.dart';

List<SingleChildWidget> homeProviders = [
  ChangeNotifierProvider<HomeProvider>(
    create: (_) => ServiceLocator.createHomeProvider(),
  ),
];
