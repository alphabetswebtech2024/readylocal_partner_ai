import 'home_stats_entity.dart';
import 'earnings_data_entity.dart';
import 'job_item_entity.dart';

class HomeDashboardEntity {
  final HomeStatsEntity stats;
  final EarningsDataEntity earnings;
  final List<JobItemEntity> jobs;

  const HomeDashboardEntity({
    this.stats = const HomeStatsEntity(),
    this.earnings = const EarningsDataEntity(),
    this.jobs = const [],
  });

  List<JobItemEntity> get ongoingJobs =>
      jobs.where((j) => j.status == 'Ongoing' || j.status == 'Started').toList();

  List<JobItemEntity> get completedJobs =>
      jobs.where((j) => j.status == 'Completed').toList();
}
