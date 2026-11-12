import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import '../../../core/di/service_locator.dart';
import '../presentation/providers/transaction_details_provider.dart';

List<SingleChildWidget> transactionDetailsProviders = [
  ChangeNotifierProvider<TransactionDetailsProvider>(
    create: (_) => ServiceLocator.createTransactionDetailsProvider(),
  ),
];
