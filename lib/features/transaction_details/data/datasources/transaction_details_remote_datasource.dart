import 'dart:convert';
import '../../../../core/network/api_constants.dart' as api;
import '../../../../core/network/api_rows.dart';
import '../../../../core/network/api_service.dart';
import '../models/transaction_detail_model.dart';

abstract class TransactionDetailsRemoteDataSource {
  Future<TransactionDetailModel> getTransactionDetails(String transactionId);
}

class TransactionDetailsRemoteDataSourceImpl implements TransactionDetailsRemoteDataSource {
  final ApiService _apiService;

  TransactionDetailsRemoteDataSourceImpl(this._apiService);

  @override
  Future<TransactionDetailModel> getTransactionDetails(String transactionId) async {
    final response = await _apiService.post(
      api.getTransactionDetails,
      data: jsonEncode({'transactionId': transactionId}),
    );

    final body = openBody(response.data);
    final data = body['data'] ?? body['Data'];
    return TransactionDetailModel.fromJson(data is Map ? Map<String, dynamic>.from(data) : body);
  }
}
