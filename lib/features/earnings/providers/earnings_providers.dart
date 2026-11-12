import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import '../../../core/di/service_locator.dart';
import '../presentation/providers/earnings_provider.dart';

List<SingleChildWidget> earningsProviders = [
  ChangeNotifierProvider<EarningsProvider>(
    create: (_) => ServiceLocator.createEarningsProvider(),
  ),
];
