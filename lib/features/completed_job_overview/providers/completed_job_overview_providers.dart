import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import '../../../core/di/service_locator.dart';
import '../presentation/providers/completed_job_provider.dart';

List<SingleChildWidget> completedJobOverviewProviders = [
  ChangeNotifierProvider<CompletedJobProvider>(
    create: (_) => ServiceLocator.createCompletedJobProvider(),
  ),
];
