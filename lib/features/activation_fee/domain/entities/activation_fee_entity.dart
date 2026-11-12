class ActivationFeeEntity {
  final double amount;
  final String transactionId;
  final String moduleId;
  final String moduleName;

  const ActivationFeeEntity({
    required this.amount,
    required this.transactionId,
    required this.moduleId,
    required this.moduleName,
  });
}
