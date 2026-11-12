import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gotask_partner/core/services/quick_location.dart';

import '../../../../core/models/User.dart';
import '../../../../core/provider/UserProvider.dart';
import '../../domain/entities/earnings_data_entity.dart';
import '../../domain/entities/home_stats_entity.dart';
import '../../domain/entities/job_item_entity.dart';
import '../../domain/usecases/get_home_details_usecase.dart';
import '../../domain/usecases/sync_location_usecase.dart';
import '../../domain/usecases/toggle_online_status_usecase.dart';
import '../../domain/usecases/update_device_token_usecase.dart';

typedef HomeController = HomeProvider;

class HomeProvider extends ChangeNotifier {
  final GetHomeDetailsUseCase getHomeDetailsUseCase;
  final ToggleOnlineStatusUseCase toggleOnlineStatusUseCase;
  final SyncLocationUseCase syncLocationUseCase;
  final UpdateDeviceTokenUseCase updateDeviceTokenUseCase;

  HomeProvider({
    required this.getHomeDetailsUseCase,
    required this.toggleOnlineStatusUseCase,
    required this.syncLocationUseCase,
    required this.updateDeviceTokenUseCase,
  });

  bool _isLoading = false;
  bool _isOnline = false;
  bool _isTogglingStatus = false;
  String? _errorMessage;

  HomeStatsEntity _stats = const HomeStatsEntity();
  EarningsDataEntity _earnings = const EarningsDataEntity();
  List<JobItemEntity> _ongoingJobs = [];
  List<JobItemEntity> _completedJobs = [];
  User? _user;

  bool get isLoading => _isLoading;
  bool get isOnline => _isOnline;
  bool get isTogglingStatus => _isTogglingStatus;
  String? get errorMessage => _errorMessage;
  HomeStatsEntity get stats => _stats;
  EarningsDataEntity get earnings => _earnings;
  List<JobItemEntity> get ongoingJobs => _ongoingJobs;
  List<JobItemEntity> get completedJobs => _completedJobs;
  User? get user => _user;

  void setInitialOnlineStatus(bool online) {
    _isOnline = online;
  }

  Future<void> loadUser() async {
    if (await UserProvider.hasUser()) {
      _user = await UserProvider.getCurrentUser();
      notifyListeners();
    }
  }

  bool _dashboardLoading = false;
  DateTime? _lastDashboardLoad;
  bool _hasDashboard = false;

  /// True once Home has data, so later refreshes update it without blocking the screen.
  bool get hasDashboard => _hasDashboard;

  Future<bool> loadDashboard({String? deviceToken}) async {
    // Home asks for this on open and again on focus. Skip a request that is
    // already running or finished a moment ago, unless the last one failed.
    final last = _lastDashboardLoad;
    if (_dashboardLoading ||
        (_hasDashboard && last != null && DateTime.now().difference(last) < const Duration(seconds: 3))) {
      return true;
    }
    _dashboardLoading = true;

    await loadUser();
    if (_user == null) {
      _dashboardLoading = false;
      return false;
    }

    _isLoading = true;
    _errorMessage = null;

    // Show the last dashboard straight away; the server's answer replaces it.
    if (!_hasDashboard) {
      final saved = await getHomeDetailsUseCase.saved(_user!.id);
      if (saved != null && !_hasDashboard) {
        _stats = saved.stats;
        _earnings = saved.earnings;
        _ongoingJobs = saved.ongoingJobs;
        _completedJobs = saved.completedJobs;
        _hasDashboard = true;
      }
    }
    notifyListeners();

    if (deviceToken != null && deviceToken.isNotEmpty) {
      updateDeviceToken(deviceToken);
    }

    // Attempt location sync
    syncLocation();

    final result = await getHomeDetailsUseCase(_user!.id);
    bool isSuccess = false;

    result.when(
      success: (dashboard) {
        _stats = dashboard.stats;
        _earnings = dashboard.earnings;
        _ongoingJobs = dashboard.ongoingJobs;
        _completedJobs = dashboard.completedJobs;
        _isLoading = false;
        isSuccess = true;
        _hasDashboard = true;
        _lastDashboardLoad = DateTime.now();
        notifyListeners();
      },
      failure: (message) {
        _errorMessage = message;
        _isLoading = false;
        isSuccess = false;
        notifyListeners();
      },
    );

    _dashboardLoading = false;
    return isSuccess;
  }

  Future<bool> toggleOnlineStatus() async {
    if (_isTogglingStatus || _user == null) return false;

    final newStatus = !_isOnline;
    _isTogglingStatus = true;
    notifyListeners();

    final result = await toggleOnlineStatusUseCase(
      partnerId: _user!.id,
      isOnline: newStatus,
    );

    bool updated = false;
    result.when(
      success: (_) {
        _isOnline = newStatus;
        _isTogglingStatus = false;
        updated = true;
        notifyListeners();

        syncLocation();
      },
      failure: (message) {
        _errorMessage = message;
        _isTogglingStatus = false;
        updated = false;
        notifyListeners();
      },
    );

    return updated;
  }

  Future<void> syncLocation() async {
    if (_user == null) return;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        log('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          log('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        log('Location permissions are permanently denied');
        return;
      }

      final position = await QuickLocation.get(limit: const Duration(seconds: 8), accuracy: LocationAccuracy.high);
      if (position == null) return;

      // As in the 6 Nov app: sent online or offline, with the status (ONLINE / OFFLINE).
      await syncLocationUseCase(
        partnerId: _user!.id,
        latitude: position.latitude,
        longitude: position.longitude,
        isOnline: _isOnline,
      );
    } catch (e) {
      log('HomeProvider failed to sync location: $e');
    }
  }

  Future<void> updateDeviceToken(String deviceToken) async {
    if (_user == null || deviceToken.isEmpty) return;
    try {
      await updateDeviceTokenUseCase(
        partnerId: _user!.id,
        deviceToken: deviceToken,
      );
    } catch (e) {
      log('HomeProvider failed to update device token: $e');
    }
  }
}
