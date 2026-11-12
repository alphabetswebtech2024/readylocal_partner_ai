import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import '../../../core/di/service_locator.dart';
import '../presentation/providers/withdraw_provider.dart';

List<SingleChildWidget> withdrawProviders = [
  ChangeNotifierProvider<WithdrawProvider>(
    create: (_) => ServiceLocator.createWithdrawProvider(),
  ),
];
