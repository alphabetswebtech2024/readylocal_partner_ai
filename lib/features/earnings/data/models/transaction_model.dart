import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.title,
    required super.amount,
    required super.dateTime,
    required super.status,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    String rawStatus = json['Status'] ?? 'PENDING';
    String mappedStatus = (rawStatus.toUpperCase() == 'SUCCESS' ||
            rawStatus.toUpperCase() == 'COMPLETED')
        ? 'Completed'
        : 'Pending';

    return TransactionModel(
      id: json['_id']?.toString() ?? '',
      title: json['Notes']?.toString() ?? 'Bank Transaction',
      amount: (json['Amount'] as num?)?.toDouble() ?? 0.0,
      dateTime: _formatDate(json['RequestedAt'] as String? ?? ''),
      status: mappedStatus,
    );
  }

  static String _formatDate(String isoDate) {
    try {
      if (isoDate.isEmpty) return '';
      DateTime dt = DateTime.parse(isoDate).toLocal();
      List<String> months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      String day = dt.day.toString().padLeft(2, '0');
      String month = months[dt.month - 1];
      String year = dt.year.toString();

      int h = dt.hour;
      String ampm = h >= 12 ? 'PM' : 'AM';
      h = h % 12;
      if (h == 0) h = 12;
      String hour = h.toString().padLeft(2, '0');
      String min = dt.minute.toString().padLeft(2, '0');

      return '$day $month $year | $hour:$min$ampm';
    } catch (_) {
      return isoDate;
    }
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'Notes': title,
        'Amount': amount,
        'RequestedAt': dateTime,
        'Status': status,
      };
}
