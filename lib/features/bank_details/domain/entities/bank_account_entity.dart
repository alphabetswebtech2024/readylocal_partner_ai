class BankAccountEntity {
  final String partnerId;
  final String accountName;
  final String accountNumber;
  final String ifsc;
  final String bankName;

  const BankAccountEntity({
    required this.partnerId,
    required this.accountName,
    required this.accountNumber,
    required this.ifsc,
    required this.bankName,
  });
}
