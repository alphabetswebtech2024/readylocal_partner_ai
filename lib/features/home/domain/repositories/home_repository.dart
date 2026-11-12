import '../../../../core/network/api_result.dart';
import '../entities/home_dashboard_entity.dart';

abstract class HomeRepository {
  /// Fetches partner dashboard info including stats, earnings, and assigned jobs.
  Future<ApiResult<HomeDashboardEntity>> getPartnerHomeDashboard(String partnerId);

  /// Toggles partner online/offline status.
  /// The last dashboard seen on this phone, shown while the new one loads.
  Future<HomeDashboardEntity?> savedDashboard(String partnerId);

  Future<ApiResult<bool>> toggleOnlineStatus({
    required String partnerId,
    required bool isOnline,
  });

  /// Syncs current GPS location with backend.
  Future<ApiResult<bool>> syncLocation({
    required String partnerId,
    required double latitude,
    required double longitude,
    required bool isOnline,
  });

  /// Updates device FCM push notification token.
  Future<ApiResult<bool>> updateDeviceToken({
    required String partnerId,
    required String deviceToken,
  });
}
