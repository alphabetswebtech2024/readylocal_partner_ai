import '../../domain/entities/earnings_summary_entity.dart';

class EarningsSummaryModel extends EarningsSummaryEntity {
  const EarningsSummaryModel({
    super.todayEarnings,
    super.weeklyEarnings,
    super.monthlyEarnings,
    super.availableBalance,
  });

  factory EarningsSummaryModel.fromJson(Map<String, dynamic> data) {
    return EarningsSummaryModel(
      todayEarnings: (data['todayEarnings'] as num?)?.toDouble() ?? 0.0,
      weeklyEarnings: (data['weeklyEarnings'] as num?)?.toDouble() ?? 0.0,
      monthlyEarnings: (data['monthlyEarnings'] as num?)?.toDouble() ?? 0.0,
      availableBalance: (data['availableBalance'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'todayEarnings': todayEarnings,
        'weeklyEarnings': weeklyEarnings,
        'monthlyEarnings': monthlyEarnings,
        'availableBalance': availableBalance,
      };
}
