import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../../core/di/service_locator.dart';
import '../presentation/providers/bank_details_provider.dart';

List<SingleChildWidget> bankDetailsProviders = [
  ChangeNotifierProvider<BankDetailsProvider>(
    create: (_) => ServiceLocator.createBankDetailsProvider(),
  ),
];
