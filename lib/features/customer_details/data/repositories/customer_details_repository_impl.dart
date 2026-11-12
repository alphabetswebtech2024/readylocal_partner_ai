import 'dart:developer';
import '../../../../core/network/api_result.dart';
import '../../domain/repositories/customer_details_repository.dart';
import '../datasources/customer_details_remote_datasource.dart';

class CustomerDetailsRepositoryImpl implements CustomerDetailsRepository {
  final CustomerDetailsRemoteDataSource remoteDataSource;

  CustomerDetailsRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<bool>> startRide({
    required String partnerId,
    required String requestId,
    required String serviceId,
  }) async {
    try {
      final success = await remoteDataSource.startRide(partnerId, requestId, serviceId);
      if (success) {
        return const ApiResult.success(true);
      }
      return const ApiResult.failure('Failed to start ride.');
    } catch (e) {
      log('Error starting ride: $e');
      return ApiResult.failure(e is Exception ? e.toString() : 'Unexpected error occurred.');
    }
  }

  @override
  Future<ApiResult<bool>> reachLocation({
    required String partnerId,
    required String requestId,
    required String serviceId,
  }) async {
    try {
      final success = await remoteDataSource.reachLocation(partnerId, requestId, serviceId);
      if (success) {
        return const ApiResult.success(true);
      }
      return const ApiResult.failure('Failed to confirm reach location.');
    } catch (e) {
      log('Error confirming reach location: $e');
      return ApiResult.failure(e is Exception ? e.toString() : 'Unexpected error occurred.');
    }
  }

  @override
  Future<ApiResult<bool>> syncLiveLocation({
    required String partnerId,
    required String customerId,
    required double latitude,
    required double longitude,
    required String status,
  }) async {
    try {
      final success = await remoteDataSource.sendLiveLocation(
        partnerId,
        customerId,
        latitude,
        longitude,
        status,
      );
      if (success) {
        return const ApiResult.success(true);
      }
      return const ApiResult.failure('Failed to sync live location.');
    } catch (e) {
      log('Error syncing live location: $e');
      return ApiResult.failure(e is Exception ? e.toString() : 'Unexpected error occurred.');
    }
  }
}
