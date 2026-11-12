import '../../domain/entities/bank_detail_entity.dart';

class BankDetailModel extends BankDetailEntity {
  const BankDetailModel({
    required super.id,
    required super.bankName,
    required super.branch,
    required super.accountHolderName,
    required super.accountNumber,
    required super.ifscCode,
  });

  factory BankDetailModel.fromJson(Map<String, dynamic> json) => BankDetailModel(
        id: json['bankAccountId']?.toString() ?? json['_id']?.toString() ?? '',
        bankName: json['bankName']?.toString() ?? '',
        branch: json['branch']?.toString() ?? 'Main Branch',
        accountHolderName: json['accountName']?.toString() ?? '',
        accountNumber: json['accountNumber']?.toString() ?? '',
        ifscCode: json['ifsc']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'bankAccountId': id,
        'bankName': bankName,
        'branch': branch,
        'accountName': accountHolderName,
        'accountNumber': accountNumber,
        'ifsc': ifscCode,
      };
}
