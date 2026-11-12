class TransactionDetailEntity {
  final String id;
  final String jobTitle;
  final double amount;
  final String dateTime;
  final String transactionId;
  final String paidThrough;
  final double baseAmount;
  final double cgst;
  final double sgst;
  final double tax;
  final double totalAmount;
  final String status; // 'Completed' | 'Pending'

  // Bank details (Nullable)
  final String? bankName;
  final String? bankBranch;
  final String? accountHolderName;
  final String? accountNumber;
  final String? ifscCode;

  const TransactionDetailEntity({
    required this.id,
    required this.jobTitle,
    required this.amount,
    required this.dateTime,
    required this.transactionId,
    required this.paidThrough,
    required this.baseAmount,
    required this.cgst,
    required this.sgst,
    required this.tax,
    required this.totalAmount,
    required this.status,
    this.bankName,
    this.bankBranch,
    this.accountHolderName,
    this.accountNumber,
    this.ifscCode,
  });
}
