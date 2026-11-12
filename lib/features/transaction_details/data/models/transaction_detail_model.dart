import '../../domain/entities/transaction_detail_entity.dart';

class TransactionDetailModel extends TransactionDetailEntity {
  const TransactionDetailModel({
    required super.id,
    required super.jobTitle,
    required super.amount,
    required super.dateTime,
    required super.transactionId,
    required super.paidThrough,
    required super.baseAmount,
    required super.cgst,
    required super.sgst,
    required super.tax,
    required super.totalAmount,
    required super.status,
    super.bankName,
    super.bankBranch,
    super.accountHolderName,
    super.accountNumber,
    super.ifscCode,
  });

  factory TransactionDetailModel.fromJson(Map<String, dynamic> json) {
    final isNested = json.containsKey('transaction') || json.containsKey('payment');

    if (isNested) {
      // --- NESTED PARSING (Job Earnings) ---
      final tx = json['transaction'] as Map<String, dynamic>? ?? {};
      final service = json['service'] as Map<String, dynamic>? ?? {};
      final payment = json['payment'] as Map<String, dynamic>? ?? {};
      final bank = json['bank'] as Map<String, dynamic>?;

      final rawStatus = tx['status']?.toString().toUpperCase() ?? 'COMPLETED';
      final mappedStatus = (rawStatus == 'SUCCESS' || rawStatus == 'COMPLETED')
          ? 'Completed'
          : 'Pending';

      final dateStr = tx['date']?.toString() ?? '';
      final timeStr = tx['time']?.toString() ?? '';
      final fullDateTime = [dateStr, timeStr].where((s) => s.isNotEmpty).join(' | ');

      return TransactionDetailModel(
        id: tx['transactionId']?.toString() ?? '',
        transactionId: tx['transactionId']?.toString() ?? '',
        jobTitle: service['serviceName']?.toString() ?? 'Service Order',
        dateTime: fullDateTime.isEmpty ? 'N/A' : fullDateTime,
        paidThrough: tx['source']?.toString().replaceAll('_', ' ') ?? 'Wallet',
        baseAmount: (payment['amount'] as num?)?.toDouble() ?? 0.0,
        cgst: (payment['cgst'] as num?)?.toDouble() ?? 0.0,
        sgst: (payment['sgst'] as num?)?.toDouble() ?? 0.0,
        tax: (payment['tax'] as num?)?.toDouble() ?? 0.0,
        totalAmount: (payment['totalAmount'] as num?)?.toDouble() ?? 0.0,
        amount: (payment['totalAmount'] as num?)?.toDouble() ?? 0.0,
        status: mappedStatus,
        bankName: bank?['bankName']?.toString(),
        bankBranch: bank?['bankBranch']?.toString(),
        accountHolderName: bank?['accountHolderName']?.toString(),
        accountNumber: bank?['accountNumber']?.toString(),
        ifscCode: bank?['ifscCode']?.toString(),
      );
    } else {
      // --- FLAT PARSING (Withdrawals / New Format) ---
      final rawStatus = json['status']?.toString().toUpperCase() ?? 'COMPLETED';
      final mappedStatus = (rawStatus == 'SUCCESS' || rawStatus == 'COMPLETED')
          ? 'Completed'
          : 'Pending';

      final dateStr = json['date']?.toString() ?? '';
      final timeStr = json['time']?.toString() ?? '';
      final fullDateTime = [dateStr, timeStr].where((s) => s.isNotEmpty).join(' | ');

      return TransactionDetailModel(
        id: json['transactionId']?.toString() ?? '',
        transactionId: json['transactionId']?.toString() ?? '',
        jobTitle: json['serviceName']?.toString() ?? json['serviceOrder']?.toString() ?? 'Service Order',
        dateTime: fullDateTime.isEmpty ? 'N/A' : fullDateTime,
        paidThrough: json['paidThrough']?.toString().replaceAll('_', ' ') ?? 'Wallet',
        baseAmount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        cgst: (json['cgst'] as num?)?.toDouble() ?? 0.0,
        sgst: (json['sgst'] as num?)?.toDouble() ?? 0.0,
        tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
        amount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
        status: mappedStatus,
        bankName: json['bankName']?.toString(),
        bankBranch: json['bankBranch']?.toString(),
        accountHolderName: json['accountHolderName']?.toString(),
        accountNumber: json['accountNumber']?.toString(),
        ifscCode: json['ifscCode']?.toString(),
      );
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'transactionId': transactionId,
        'jobTitle': jobTitle,
        'amount': amount,
        'dateTime': dateTime,
        'paidThrough': paidThrough,
        'baseAmount': baseAmount,
        'cgst': cgst,
        'sgst': sgst,
        'tax': tax,
        'totalAmount': totalAmount,
        'status': status,
        'bankName': bankName,
        'bankBranch': bankBranch,
        'accountHolderName': accountHolderName,
        'accountNumber': accountNumber,
        'ifscCode': ifscCode,
      };
}
