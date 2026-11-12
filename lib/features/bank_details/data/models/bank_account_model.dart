import '../../domain/entities/bank_account_entity.dart';

class BankAccountModel extends BankAccountEntity {
  const BankAccountModel({
    required super.partnerId,
    required super.accountName,
    required super.accountNumber,
    required super.ifsc,
    required super.bankName,
  });

  Map<String, dynamic> toJson() => {
    'partnerId': partnerId,
    'accountHolderName': accountName,
    'accountNumber': accountNumber,
    'ifscCode': ifsc,
    'bankName': bankName,
  };
}
