import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../../core/di/service_locator.dart';
import '../presentation/providers/customer_details_provider.dart';

List<SingleChildWidget> get customerDetailsProviders => [
  ChangeNotifierProvider<CustomerDetailsProvider>(
    create: (_) => ServiceLocator.createCustomerDetailsController(),
  ),
];
