import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../../core/di/service_locator.dart';
import '../presentation/providers/medical_setup_provider.dart';

List<SingleChildWidget> medicalSetupProviders = [
  ChangeNotifierProvider<MedicalSetupProvider>(
    create: (_) => ServiceLocator.createMedicalSetupProvider(),
  ),
];
