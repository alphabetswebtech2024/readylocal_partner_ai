import '../../../../core/network/api_result.dart';

abstract class CustomerDetailsRepository {
  Future<ApiResult<bool>> startRide({
    required String partnerId,
    required String requestId,
    required String serviceId,
  });

  Future<ApiResult<bool>> reachLocation({
    required String partnerId,
    required String requestId,
    required String serviceId,
  });

  Future<ApiResult<bool>> syncLiveLocation({
    required String partnerId,
    required String customerId,
    required double latitude,
    required double longitude,
    required String status,
  });
}
