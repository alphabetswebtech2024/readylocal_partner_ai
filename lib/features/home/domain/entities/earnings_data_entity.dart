class EarningsDataEntity {
  final double todayEarnings;
  final int todayJobs;
  final double weeklyEarnings;
  final int weeklyJobs;
  final double monthlyEarnings;
  final int monthlyJobs;

  const EarningsDataEntity({
    this.todayEarnings = 0.0,
    this.todayJobs = 0,
    this.weeklyEarnings = 0.0,
    this.weeklyJobs = 0,
    this.monthlyEarnings = 0.0,
    this.monthlyJobs = 0,
  });
}
