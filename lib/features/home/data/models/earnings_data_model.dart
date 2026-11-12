import '../../domain/entities/earnings_data_entity.dart';

class EarningsDataModel extends EarningsDataEntity {
  const EarningsDataModel({
    super.todayEarnings,
    super.todayJobs,
    super.weeklyEarnings,
    super.weeklyJobs,
    super.monthlyEarnings,
    super.monthlyJobs,
  });

  factory EarningsDataModel.fromJson(Map<String, dynamic> json) =>
      EarningsDataModel(
        todayEarnings: (json['todayEarnings'] as num?)?.toDouble() ?? 0.0,
        todayJobs: (json['todayJobs'] as num?)?.toInt() ?? 0,
        weeklyEarnings: (json['weeklyEarnings'] as num?)?.toDouble() ?? 0.0,
        weeklyJobs: (json['weeklyJobs'] as num?)?.toInt() ?? 0,
        monthlyEarnings: (json['monthlyEarnings'] as num?)?.toDouble() ?? 0.0,
        monthlyJobs: (json['monthlyJobs'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'todayEarnings': todayEarnings,
        'todayJobs': todayJobs,
        'weeklyEarnings': weeklyEarnings,
        'weeklyJobs': weeklyJobs,
        'monthlyEarnings': monthlyEarnings,
        'monthlyJobs': monthlyJobs,
      };
}
