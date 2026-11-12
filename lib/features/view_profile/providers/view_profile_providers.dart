import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import '../../../core/di/service_locator.dart';
import '../presentation/providers/view_profile_provider.dart';

List<SingleChildWidget> viewProfileProviders = [
  ChangeNotifierProvider<ViewProfileProvider>(
    create: (_) => ServiceLocator.createViewProfileProvider(),
  ),
];
