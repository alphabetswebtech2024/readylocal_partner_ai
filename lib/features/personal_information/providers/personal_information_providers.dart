import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../../core/di/service_locator.dart';
import '../presentation/providers/personal_information_provider.dart';

List<SingleChildWidget> personalInformationProviders = [
  ChangeNotifierProvider<PersonalInformationProvider>(
    create: (_) => ServiceLocator.createPersonalInformationProvider(),
  ),
];
