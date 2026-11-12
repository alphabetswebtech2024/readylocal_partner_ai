// lib/screens/jobs/CustomerDetailsScreen.dart

import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gotask_partner/core/utils/AppConstants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gotask_partner/core/design/app_top_bar.dart';
import 'package:gotask_partner/core/services/quick_location.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../main.dart' show userID;
import '../../../job_progress/presentation/screens/job_progress_screen.dart';
import '../../data/models/customer_details_model.dart';
import '../providers/customer_details_provider.dart';
import 'package:gotask_partner/core/design/app_colors.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';

// ─── CustomerDetailsScreen ────────────────────────────────────────────────────

class CustomerDetailsScreen extends StatefulWidget {
  final CustomerDetails details;

  const CustomerDetailsScreen({super.key, required this.details});

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  static const Color _blue = AppColors.primaryPressed;

  late final CustomerDetailsController _controller;
  late CustomerDetails _d;

  GoogleMapController? _mapController;
  Position? _currentPosition;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  final String googleApiKey = GoogleAPIKey;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _d = widget.details;
    _controller = ServiceLocator.createCustomerDetailsController();
    _controller.initializeState(_d.nextStep, _d.distance);

    _getCurrentLocationAndRoute().then((_) {
      if (_controller.rideState == RideState.reached) {
        _startLocationUpdates();
      }
    });
  }

  @override
  void dispose() {
    _stopLocationUpdates();
    _mapController?.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _startLocationUpdates() {
    developer.log("Started Live Location Sync Timer");
    _sendLocationUpdate();

    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _sendLocationUpdate();
    });
  }

  void _stopLocationUpdates() {
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  Future<void> _sendLocationUpdate() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      // Live tracking: fresh position only, but never hangs waiting for GPS.
      final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 15)));

      double liveMeters = Geolocator.distanceBetween(
          pos.latitude, pos.longitude, _d.latitude, _d.longitude);
      _controller.updateLiveDistance((liveMeters / 1000).toStringAsFixed(1));

      await _controller.syncLiveLocation(
        partnerId: userID,
        latitude: pos.latitude,
        longitude: pos.longitude,
        customerId: _d.customerId,
      );
    } catch (e) {
      developer.log('Live location sync error: $e');
    }
  }

  Future<void> _getCurrentLocationAndRoute() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
    }

    _currentPosition = await QuickLocation.get();
    if (!mounted) return;
    if (_currentPosition == null) return;

    final start =
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    final destination = LatLng(_d.latitude, _d.longitude);

    double initialMeters = Geolocator.distanceBetween(start.latitude,
        start.longitude, destination.latitude, destination.longitude);

    setState(() {
      _controller
          .updateLiveDistance((initialMeters / 1000).toStringAsFixed(1));

      _markers.add(Marker(
          markerId: const MarkerId('start'),
          position: start,
          infoWindow: InfoWindow(title: context.l10n.mapStartLocation),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)));
      _markers.add(Marker(
          markerId: const MarkerId('destination'),
          position: destination,
          infoWindow: InfoWindow(title: context.l10n.mapDestination),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)));
    });

    if (_mapController != null) {
      LatLngBounds bounds;
      if (start.latitude > destination.latitude &&
          start.longitude > destination.longitude) {
        bounds = LatLngBounds(southwest: destination, northeast: start);
      } else if (start.longitude > destination.longitude) {
        bounds = LatLngBounds(
            southwest: LatLng(start.latitude, destination.longitude),
            northeast: LatLng(destination.latitude, start.longitude));
      } else if (start.latitude > destination.latitude) {
        bounds = LatLngBounds(
            southwest: LatLng(destination.latitude, start.longitude),
            northeast: LatLng(start.latitude, destination.longitude));
      } else {
        bounds = LatLngBounds(southwest: start, northeast: destination);
      }
      _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
    }

    _drawPolyline(start, destination);
  }

  List<LatLng> _getCurvedPoints(LatLng start, LatLng dest) {
    final double lat1 = start.latitude;
    final double lng1 = start.longitude;
    final double lat2 = dest.latitude;
    final double lng2 = dest.longitude;

    final double midLat = (lat1 + lat2) / 2;
    final double midLng = (lng1 + lng2) / 2;

    final double latDiff = lat2 - lat1;
    final double lngDiff = lng2 - lng1;
    final double controlLat = midLat - (lngDiff * 0.2);
    final double controlLng = midLng + (latDiff * 0.2);

    List<LatLng> path = [];
    for (int i = 0; i <= 50; i++) {
      double t = i / 50.0;
      double lat = (1 - t) * (1 - t) * lat1 +
          2 * (1 - t) * t * controlLat +
          t * t * lat2;
      double lng = (1 - t) * (1 - t) * lng1 +
          2 * (1 - t) * t * controlLng +
          t * t * lng2;
      path.add(LatLng(lat, lng));
    }
    return path;
  }

  void _drawPolyline(LatLng start, LatLng dest) {
    List<LatLng> curvedCoordinates = _getCurvedPoints(start, dest);

    setState(() {
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('direct_route'),
          color: Colors.black,
          points: curvedCoordinates,
          width: 4,
          geodesic: true,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      );
    });
  }

  Future<void> _openMap() async {
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${_d.latitude},${_d.longitude}&travelmode=driving');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _callCustomer() async {
    final uri = Uri.parse('tel:${_d.customerPhone}');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _handleSliderAction() async {
    final currentState = _controller.rideState;

    final success = await _controller.handleSliderAction(
      partnerId: userID,
      requestId: _d.requestId,
      serviceId: _d.serviceId,
    );

    if (!mounted) return;

    if (success) {
      if (currentState == RideState.start) {
        AppSnackBar.success(context.l10n.rideStartedSuccess);
        _startLocationUpdates();
      } else {
        _stopLocationUpdates();
        AppSnackBar.success(context.l10n.reachedRecorded);
        _goToProgress();
      }
    } else {
      AppSnackBar.error(_controller.errorMessage ?? context.l10n.statusUpdateFailed);
    }
  }

  void _goToProgress() {
    // Through the router: a screen pushed directly with Navigator stayed on top
    // when "Back to home" ran, returning the partner to the finished job.
    context.pushReplacement(
      AppRoutes.jobProgress,
      extra: {
        'jobId': _d.jobId,
        'jobTitle': _d.jobTitle,
        'jobAmount': _d.jobAmount,
        'jobDateTime': _d.jobDateTime,
        'isInstant': _d.isInstant,
        'etaLabel': _d.etaLabel,
        'aboutPoints': _d.aboutPoints,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
 top: false,
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMap(),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildGetDirection(),
                              const SizedBox(height: 20),
                              _buildDivider(),
                              const SizedBox(height: 20),
                              _buildCustomerRow(),
                              const SizedBox(height: 24),
                              if (_d.customerEmail.isNotEmpty)
                                _buildInfoRow(context.l10n.labelEmail, _d.customerEmail),
                              _buildInfoRow(
                                  context.l10n.labelServiceBookedDate, _d.serviceBookedDate),
                              _buildInfoRow(
                                  context.l10n.labelServiceBookedTime, _d.serviceBookedTime),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildSliderWrapper(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar() {
    return AppTopBar(title: context.l10n.customerDetailsTitle);
  }

  Widget _buildMap() {
    return SizedBox(
      height: 320,
      width: double.infinity,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
            target: LatLng(_d.latitude, _d.longitude), zoom: 14),
        markers: _markers,
        polylines: _polylines,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        buildingsEnabled: false, // lighter on low-memory phones
        onMapCreated: (controller) => _mapController = controller,
      ),
    );
  }

  Widget _buildGetDirection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.getDirection,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black)),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                _d.address,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textMuted, height: 1.5),
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: _openMap,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.success],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(Icons.location_on,
                          size: 10, color: Colors.white),
                    ),
                    const SizedBox(width: 6),
                    Text(context.l10n.mapLabel,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.black)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomerRow() {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: _blue.withOpacity(0.1),
          child: _d.customerAvatarUrl != null
              ? Text(
                  _d.customerName.isNotEmpty
                      ? _d.customerName[0].toUpperCase()
                      : 'C',
                  style: const TextStyle(
                      color: _blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_d.customerName,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black)),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: AppColors.warning, width: 1.2),
                  color: AppColors.warningTint,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on,
                        color: AppColors.primary, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      context.l10n.jobDistanceKm(_controller.liveDistance),
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.black),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: _callCustomer,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary, width: 1.5)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.call_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(context.l10n.callLabel,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
              width: 160,
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted))),
          Expanded(
              child: Text(value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black))),
        ],
      ),
    );
  }

  Widget _buildDivider() =>
      Container(height: 1, color: AppColors.border);

  Widget _buildSliderWrapper() {
    String sliderText = _controller.rideState == RideState.start
        ? context.l10n.startRide
        : context.l10n.reachedLocation;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(color: Colors.white),
      child: CustomSlideButton(
        key: ValueKey(_controller.rideState),
        text: sliderText,
        isLoading: _controller.isLoadingSlider,
        onSlided: _handleSliderAction,
      ),
    );
  }
}

class CustomSlideButton extends StatefulWidget {
  final String text;
  final bool isLoading;
  final VoidCallback onSlided;

  const CustomSlideButton({
    super.key,
    required this.text,
    required this.isLoading,
    required this.onSlided,
  });

  @override
  State<CustomSlideButton> createState() => _CustomSlideButtonState();
}

class _CustomSlideButtonState extends State<CustomSlideButton>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0.0;
  final double _thumbSize = 48.0;
  bool _slided = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        final double maxDragPosition = maxWidth - _thumbSize - 8;

        return Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primaryTint,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Center(
                child: Text(
                  widget.isLoading ? context.l10n.processing : widget.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: _slided
                    ? const Duration(milliseconds: 0)
                    : const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                left: _dragPosition + 4,
                child: GestureDetector(
                  onPanUpdate: widget.isLoading || _slided
                      ? null
                      : (details) {
                          setState(() {
                            _dragPosition += details.delta.dx;
                            if (_dragPosition < 0) _dragPosition = 0;
                            if (_dragPosition > maxDragPosition) {
                              _dragPosition = maxDragPosition;
                            }
                          });
                        },
                  onPanEnd: widget.isLoading || _slided
                      ? null
                      : (details) {
                          if (_dragPosition > maxDragPosition * 0.75) {
                            setState(() {
                              _dragPosition = maxDragPosition;
                              _slided = true;
                            });
                            widget.onSlided();
                          } else {
                            setState(() {
                              _dragPosition = 0.0;
                            });
                          }
                        },
                  child: Container(
                    width: _thumbSize,
                    height: _thumbSize,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: widget.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: AppColors.primary, strokeWidth: 2.5),
                          )
                        : const Icon(Icons.double_arrow_rounded,
                            color: AppColors.primary, size: 24),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
