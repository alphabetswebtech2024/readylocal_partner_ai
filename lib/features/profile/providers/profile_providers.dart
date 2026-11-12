import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import '../../../core/di/service_locator.dart';
import '../presentation/providers/profile_provider.dart';

List<SingleChildWidget> profileProviders = [
  ChangeNotifierProvider<ProfileProvider>(
    create: (_) => ServiceLocator.createProfileProvider(),
  ),
];
