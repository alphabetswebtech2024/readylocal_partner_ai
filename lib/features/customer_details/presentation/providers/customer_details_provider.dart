import 'package:flutter/foundation.dart';
import '../../domain/usecases/reach_location_usecase.dart';
import '../../domain/usecases/start_ride_usecase.dart';
import '../../domain/usecases/sync_live_location_usecase.dart';

enum RideState { start, reached }

typedef CustomerDetailsController = CustomerDetailsProvider;

class CustomerDetailsProvider extends ChangeNotifier {
  final StartRideUseCase startRideUseCase;
  final ReachLocationUseCase reachLocationUseCase;
  final SyncLiveLocationUseCase syncLiveLocationUseCase;

  CustomerDetailsProvider({
    required this.startRideUseCase,
    required this.reachLocationUseCase,
    required this.syncLiveLocationUseCase,
  });

  RideState _rideState = RideState.start;
  bool _isLoadingSlider = false;
  String? _errorMessage;
  String _liveDistance = "N/A";

  RideState get rideState => _rideState;
  bool get isLoadingSlider => _isLoadingSlider;
  String? get errorMessage => _errorMessage;
  String get liveDistance => _liveDistance;

  void initializeState(String nextStep, String initialDistance) {
    _liveDistance = initialDistance;
    if (nextStep == 'REACHED_CONFIRM' || nextStep == 'REACHED') {
      _rideState = RideState.reached;
    } else {
      _rideState = RideState.start;
    }
    notifyListeners();
  }

  void updateLiveDistance(String distance) {
    if (_liveDistance != distance) {
      _liveDistance = distance;
      notifyListeners();
    }
  }

  Future<bool> handleSliderAction({
    required String partnerId,
    required String requestId,
    required String serviceId,
  }) async {
    _isLoadingSlider = true;
    _errorMessage = null;
    notifyListeners();

    bool isSuccess = false;

    if (_rideState == RideState.start) {
      final result = await startRideUseCase(
        partnerId: partnerId,
        requestId: requestId,
        serviceId: serviceId,
      );

      result.when(
        success: (_) {
          _rideState = RideState.reached;
          _isLoadingSlider = false;
          isSuccess = true;
          notifyListeners();
        },
        failure: (message) {
          _errorMessage = message;
          _isLoadingSlider = false;
          isSuccess = false;
          notifyListeners();
        },
      );
    } else {
      final result = await reachLocationUseCase(
        partnerId: partnerId,
        requestId: requestId,
        serviceId: serviceId,
      );

      result.when(
        success: (_) {
          _isLoadingSlider = false;
          isSuccess = true;
          notifyListeners();
        },
        failure: (message) {
          _errorMessage = message;
          _isLoadingSlider = false;
          isSuccess = false;
          notifyListeners();
        },
      );
    }

    return isSuccess;
  }

  Future<void> syncLiveLocation({
    required String partnerId,
    required double latitude,
    required double longitude,
    required String customerId,
    String status = "ON_THE_WAY",
  }) => syncLocation(
    partnerId: partnerId,
    customerId: customerId,
    latitude: latitude,
    longitude: longitude,
    status: status,
  );

  Future<void> syncLocation({
    required String partnerId,
    required String customerId,
    required double latitude,
    required double longitude,
    required String status,
  }) async {
    await syncLiveLocationUseCase(
      partnerId: partnerId,
      customerId: customerId,
      latitude: latitude,
      longitude: longitude,
      status: status,
    );
  }
}
