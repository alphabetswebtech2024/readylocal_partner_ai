import 'dart:convert';
import '../../../../core/network/api_constants.dart' as api;
import '../../../../core/network/api_service.dart';
import '../models/payment_success_model.dart';

abstract class PaymentSuccessRemoteDataSource {
  Future<PaymentSuccessModel> updateDeviceToken({
    required String partnerId,
    required String deviceToken,
  });
}

class PaymentSuccessRemoteDataSourceImpl implements PaymentSuccessRemoteDataSource {
  final ApiService _apiService;

  PaymentSuccessRemoteDataSourceImpl(this._apiService);

  @override
  Future<PaymentSuccessModel> updateDeviceToken({
    required String partnerId,
    required String deviceToken,
  }) async {
    final response = await _apiService.post(
      api.updateDeviceToken,
      data: jsonEncode({
        'partnerId': partnerId,
        'partnerID': partnerId, // same API as Home, which sends partnerID
        'deviceToken': deviceToken,
      }),
    );
    final body = response.data;
    final isOk = body is Map && body['Status'] == 'SUCCESS';
    return PaymentSuccessModel.create(isSynced: isOk);
  }
}
