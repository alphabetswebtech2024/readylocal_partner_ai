import 'package:geolocator/geolocator.dart';

import 'quick_location.dart';

/// Centralized Location Service for geolocation queries and distance computations.
class LocationService {
  LocationService._();

  /// Calculates dynamic distance between device current position and target source coordinates.
  /// Falls back to [fallback] if location is unavailable or permissions are denied.
  static Future<String> getDynamicDistance(
    Map<String, dynamic>? apiData,
    String fallback,
  ) async {
    if (apiData == null ||
        apiData['SourceLocation'] == null ||
        apiData['SourceLocation']['coordinates'] == null) {
      return fallback;
    }

    try {
      final coords = apiData['SourceLocation']['coordinates'] as List;
      final targetLng = (coords[0] as num).toDouble();
      final targetLat = (coords[1] as num).toDouble();

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return fallback;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return fallback;
        }
      }

      // Opening a job waits for this, so it must not wait for a fresh GPS fix.
      final pos = await QuickLocation.get();
      if (pos == null) return fallback;

      double distMeters = Geolocator.distanceBetween(
        pos.latitude,
        pos.longitude,
        targetLat,
        targetLng,
      );

      return (distMeters / 1000).toStringAsFixed(1);
    } catch (_) {
      return fallback;
    }
  }
}

/// Backward compatibility function
Future<String> getDynamicDistance(
  Map<String, dynamic>? apiData,
  String fallback,
) =>
    LocationService.getDynamicDistance(apiData, fallback);
