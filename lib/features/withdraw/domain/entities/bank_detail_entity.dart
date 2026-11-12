class BankDetailEntity {
  final String id;
  final String bankName;
  final String branch;
  final String accountHolderName;
  final String accountNumber;
  final String ifscCode;

  const BankDetailEntity({
    required this.id,
    required this.bankName,
    required this.branch,
    required this.accountHolderName,
    required this.accountNumber,
    required this.ifscCode,
  });
}
