import 'dart:io';
import 'package:dio/dio.dart';
import 'package:gotask_partner/core/network/api_client.dart' show ApiException;
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';

import '../../../../core/network/api_result.dart';
import '../../domain/entities/home_dashboard_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';
import '../models/home_stats_model.dart';
import '../models/earnings_data_model.dart';
import '../models/job_item_model.dart';

/// Failure text for "the server could not be reached"; Home keeps the partner
/// signed in for this one.
const String kHomeNetworkFailure = 'home_network_unavailable';

/// True when the request never got an answer from the server.
bool isNetworkFailure(Object e) {
  if (e is SocketException || e is TimeoutException) return true;
  if (e is DioException) {
    final inner = e.error;
    if (inner is ApiException) return inner.statusCode == null && e.response == null;
    return e.response == null;
  }
  return false;
}

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<HomeDashboardEntity>> getPartnerHomeDashboard(String partnerId) async {
    try {
      final rawData = await remoteDataSource.getPartnerRawDetails(partnerId);
      final dashboard = _toDashboard(rawData);
      unawaited(_saveDashboard(partnerId, rawData));
      return ApiResult.success(dashboard);
    } catch (e) {
      log('Error fetching partner home dashboard: $e');
      // No answer from the server (weak signal, timeout): not a login problem.
      if (isNetworkFailure(e)) return const ApiResult.failure(kHomeNetworkFailure);
      return ApiResult.failure(e is Exception ? e.toString() : 'Unexpected error occurred.');
    }
  }

  HomeDashboardEntity _toDashboard(Map<String, dynamic> rawData) {
    final rawStats = rawData['jobStats'] as Map<String, dynamic>? ?? {};
    final rawEarnings = rawData['earningDetails'] as Map<String, dynamic>? ?? {};
    final rawJobsList = rawData['AcceptOrReject'] as List<dynamic>? ?? [];
    return HomeDashboardEntity(
      stats: HomeStatsModel.fromJson(rawStats),
      earnings: EarningsDataModel.fromJson(rawEarnings),
      jobs: rawJobsList.map((e) => JobItemModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<void> _saveDashboard(String partnerId, Map<String, dynamic> rawData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'homeDashboard_$partnerId',
        jsonEncode({
          'jobStats': rawData['jobStats'],
          'earningDetails': rawData['earningDetails'],
          'AcceptOrReject': rawData['AcceptOrReject'],
        }),
      );
    } catch (e) {
      log('Could not save dashboard: $e');
    }
  }

  @override
  Future<HomeDashboardEntity?> savedDashboard(String partnerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('homeDashboard_$partnerId');
      if (saved == null) return null;
      return _toDashboard(Map<String, dynamic>.from(jsonDecode(saved) as Map));
    } catch (e) {
      return null;
    }
  }

  @override
  Future<ApiResult<bool>> toggleOnlineStatus({
    required String partnerId,
    required bool isOnline,
  }) async {
    try {
      final statusStr = isOnline ? 'ONLINE' : 'OFFLINE'; // as in the 6 Nov app
      final success = await remoteDataSource.updateOnlineStatus(partnerId, statusStr);
      if (success) {
        return const ApiResult.success(true);
      }
      return const ApiResult.failure('Failed to update online status.');
    } catch (e) {
      log('Error updating online status: $e');
      return ApiResult.failure(e is Exception ? e.toString() : 'Unexpected error occurred.');
    }
  }

  @override
  Future<ApiResult<bool>> syncLocation({
    required String partnerId,
    required double latitude,
    required double longitude,
    required bool isOnline,
  }) async {
    try {
      final statusStr = isOnline ? 'ONLINE' : 'OFFLINE';
      final success = await remoteDataSource.sendLocation(partnerId, latitude, longitude, statusStr);
      if (success) {
        return const ApiResult.success(true);
      }
      return const ApiResult.failure('Failed to sync location.');
    } catch (e) {
      log('Error syncing location: $e');
      return ApiResult.failure(e is Exception ? e.toString() : 'Unexpected error occurred.');
    }
  }

  @override
  Future<ApiResult<bool>> updateDeviceToken({
    required String partnerId,
    required String deviceToken,
  }) async {
    try {
      final success = await remoteDataSource.updateDeviceToken(partnerId, deviceToken);
      if (success) {
        return const ApiResult.success(true);
      }
      return const ApiResult.failure('Failed to update device token.');
    } catch (e) {
      log('Error updating device token: $e');
      return ApiResult.failure(e is Exception ? e.toString() : 'Unexpected error occurred.');
    }
  }
}
