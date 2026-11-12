import 'dart:convert';
import '../../../../core/network/api_constants.dart' as api;
import '../../../../core/network/api_response_check.dart';
import '../../../../core/network/api_service.dart';

abstract class ActivationFeeRemoteDataSource {
  Future<bool> saveTransaction({
    required String partnerId,
    required String transactionId,
    required double amount,
    required String moduleId,
    required String moduleName,
  });
}

class ActivationFeeRemoteDataSourceImpl implements ActivationFeeRemoteDataSource {
  final ApiService _apiService;

  ActivationFeeRemoteDataSourceImpl(this._apiService);

  @override
  Future<bool> saveTransaction({
    required String partnerId,
    required String transactionId,
    required double amount,
    required String moduleId,
    required String moduleName,
  }) async {
    final response = await _apiService.post(
      api.saveTransaction,
      data: jsonEncode({
        'PartnerID': partnerId,
        'CategoryName': 'Registration Fee',
        'TransactionID': transactionId,
        'TransactionAmount': amount,
        'Remarks': 'Registration Fee',
        'TransactionMode': 'Razorpay',
        'TransactionDoneBy': 'Partner',
        'isAnyStoreService': 'false',
        'ModuleID': moduleId,
        'ModuleName': moduleName,
      }),
    );
    return apiCallSucceeded(response);
  }
}
