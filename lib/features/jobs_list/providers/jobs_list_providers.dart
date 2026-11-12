import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import '../../../core/di/service_locator.dart';
import '../presentation/providers/jobs_list_provider.dart';

List<SingleChildWidget> jobsListProviders = [
  ChangeNotifierProvider<JobsListProvider>(
    create: (_) => ServiceLocator.createJobsListProvider(),
  ),
];
