class HomeStatsEntity {
  final int totalAssigned;
  final int accepted;
  final int rejected;
  final int completed;
  final int cancelled;
  final int failed;

  const HomeStatsEntity({
    this.totalAssigned = 0,
    this.accepted = 0,
    this.rejected = 0,
    this.completed = 0,
    this.cancelled = 0,
    this.failed = 0,
  });
}
