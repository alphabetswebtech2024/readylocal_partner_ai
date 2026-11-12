class TransactionEntity {
  final String id;
  final String title;
  final double amount;
  final String dateTime;
  final String status; // 'Completed' | 'Pending'

  const TransactionEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.dateTime,
    required this.status,
  });
}
