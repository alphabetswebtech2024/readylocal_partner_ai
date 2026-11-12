import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../../core/di/service_locator.dart';
import '../presentation/providers/activation_fee_provider.dart';

List<SingleChildWidget> activationFeeProviders = [
  ChangeNotifierProvider<ActivationFeeProvider>(
    create: (_) => ServiceLocator.createActivationFeeProvider(),
  ),
];
