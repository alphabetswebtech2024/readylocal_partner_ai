import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import '../../../core/di/service_locator.dart';
import '../presentation/providers/job_overview_provider.dart';

List<SingleChildWidget> jobOverviewProviders = [
  ChangeNotifierProvider<JobOverviewProvider>(
    create: (_) => ServiceLocator.createJobOverviewProvider(),
  ),
];
