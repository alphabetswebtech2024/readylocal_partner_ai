class EarningsSummaryEntity {
  final double todayEarnings;
  final double weeklyEarnings;
  final double monthlyEarnings;
  final double availableBalance;

  const EarningsSummaryEntity({
    this.todayEarnings = 0.0,
    this.weeklyEarnings = 0.0,
    this.monthlyEarnings = 0.0,
    this.availableBalance = 0.0,
  });
}
