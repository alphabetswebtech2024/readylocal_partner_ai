import '../../domain/entities/home_stats_entity.dart';

class HomeStatsModel extends HomeStatsEntity {
  const HomeStatsModel({
    super.totalAssigned,
    super.accepted,
    super.rejected,
    super.completed,
    super.cancelled,
    super.failed,
  });

  factory HomeStatsModel.fromJson(Map<String, dynamic> json) => HomeStatsModel(
        totalAssigned: (json['totalAssigned'] as num?)?.toInt() ?? 0,
        accepted: (json['accepted'] as num?)?.toInt() ?? 0,
        rejected: (json['rejected'] as num?)?.toInt() ?? 0,
        completed: (json['completed'] as num?)?.toInt() ?? 0,
        cancelled: (json['cancelled'] as num?)?.toInt() ?? 0,
        failed: (json['failed'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'totalAssigned': totalAssigned,
        'accepted': accepted,
        'rejected': rejected,
        'completed': completed,
        'cancelled': cancelled,
        'failed': failed,
      };
}
