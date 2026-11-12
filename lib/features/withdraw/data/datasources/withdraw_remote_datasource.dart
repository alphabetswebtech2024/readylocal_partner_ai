import 'dart:convert';
import '../../../../core/network/api_constants.dart' as api;
import '../../../../core/network/api_rows.dart';
import '../../../../core/network/api_service.dart';
import '../models/bank_detail_model.dart';
import 'package:gotask_partner/core/network/api_response_check.dart';

abstract class WithdrawRemoteDataSource {
  Future<List<BankDetailModel>> getBankAccounts(String partnerId);
  Future<bool> requestWithdrawal(Map<String, dynamic> payload);
}

class WithdrawRemoteDataSourceImpl implements WithdrawRemoteDataSource {
  final ApiService _apiService;

  WithdrawRemoteDataSourceImpl(this._apiService);

  @override
  Future<List<BankDetailModel>> getBankAccounts(String partnerId) async {
    final response = await _apiService.post(
      api.listBankAccounts,
      data: jsonEncode({'partnerId': partnerId}),
    );

    final data = openBody(response.data)['data'];
    final rawList = data is Map ? data['bankAccounts'] : null;
    if (rawList is! List) return const [];
    return rawList
        .whereType<Map>()
        .map((e) => BankDetailModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<bool> requestWithdrawal(Map<String, dynamic> payload) async {
    final response = await _apiService.post(
      api.withdrawRequest,
      data: jsonEncode(payload),
    );

    // Any answer from the server is accepted, as in the 6 Nov app, except an
    // explicit refusal: then the partner sees the server's own reason.
    if (!apiCallSucceeded(response)) {
      final body = openBody(response.data);
      final reason = (body['Message'] ?? body['message'] ?? '').toString().trim();
      throw Exception(reason.isEmpty ? 'Failed to submit withdrawal request.' : reason);
    }
    return true;
  }
}
