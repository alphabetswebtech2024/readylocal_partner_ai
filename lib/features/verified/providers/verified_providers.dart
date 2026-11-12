import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../../core/di/service_locator.dart';
import '../presentation/providers/verified_provider.dart';

List<SingleChildWidget> verifiedProviders = [
  ChangeNotifierProvider<VerifiedProvider>(
    create: (_) => ServiceLocator.createVerifiedProvider(),
  ),
];
