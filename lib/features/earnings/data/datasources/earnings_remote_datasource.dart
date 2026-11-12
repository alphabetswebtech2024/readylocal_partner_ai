import 'dart:convert';
import '../../../../core/network/api_constants.dart' as api;
import '../../../../core/network/api_service.dart';

abstract class EarningsRemoteDataSource {
  Future<Map<String, dynamic>> getEarningsSummary(String partnerId);
}

class EarningsRemoteDataSourceImpl implements EarningsRemoteDataSource {
  final ApiService _apiService;

  EarningsRemoteDataSourceImpl(this._apiService);

  @override
  Future<Map<String, dynamic>> getEarningsSummary(String partnerId) async {
    final response = await _apiService.post(
      api.getEarningsSummary,
      data: jsonEncode({'partnerId': partnerId}),
    );

    final body = response.data;
    if (body is! Map) {
      throw Exception('Invalid response format.');
    }

    // 6 Nov app: no data yet = ₹0 and no transactions, not an error.
    final data = body['Data'];
    return data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
  }
}
