import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../../core/di/service_locator.dart';
import '../presentation/providers/job_progress_provider.dart';

List<SingleChildWidget> get jobProgressProviders => [
  ChangeNotifierProvider<JobProgressProvider>(
    create: (_) => ServiceLocator.createJobProgressProvider(),
  ),
];
