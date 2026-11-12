import 'dart:convert';
import '../../../../core/network/api_constants.dart' as api;
import '../../../../core/network/api_rows.dart';
import '../../../../core/network/api_service.dart';

abstract class BankDetailsRemoteDataSource {
  Future<bool> addBankAccount({
    required String partnerId,
    required String accountName,
    required String accountNumber,
    required String ifsc,
    required String bankName,
  });
}

class BankDetailsRemoteDataSourceImpl implements BankDetailsRemoteDataSource {
  final ApiService _apiService;

  BankDetailsRemoteDataSourceImpl(this._apiService);

  @override
  Future<bool> addBankAccount({
    required String partnerId,
    required String accountName,
    required String accountNumber,
    required String ifsc,
    required String bankName,
  }) async {
    final response = await _apiService.post(
      api.addBankDetail,
      data: jsonEncode({
        'partnerId': partnerId,
        'accountName': accountName,
        'accountNumber': accountNumber,
        'ifsc': ifsc,
        'bankName': bankName,
      }),
    );
    final body = openBody(response.data);
    return body['success'] == true || body['Status'] == 'SUCCESS';
  }
}
