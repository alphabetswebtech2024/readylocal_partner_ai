import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import '../../../core/di/service_locator.dart';
import '../presentation/providers/payment_failed_provider.dart';

List<SingleChildWidget> paymentFailedProviders = [
  ChangeNotifierProvider<PaymentFailedProvider>(
    create: (_) => ServiceLocator.createPaymentFailedProvider(),
  ),
];
