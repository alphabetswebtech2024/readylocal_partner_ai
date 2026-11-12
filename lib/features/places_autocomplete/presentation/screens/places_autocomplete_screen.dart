import 'dart:async';
import 'dart:developer' show log;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:gotask_partner/core/design/app_top_bar.dart';
import 'package:gotask_partner/core/services/quick_location.dart';

import '../../../../core/utils/AppConstants.dart';
import '../../../../core/widgets/common_loading_overlay.dart';
import '../../domain/entities/place_prediction_entity.dart';
import 'package:gotask_partner/core/design/app_colors.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';

typedef PlaceDetail = PlaceDetailEntity;

class PlacesAutocompleteScreen extends StatefulWidget {
  const PlacesAutocompleteScreen({super.key});

  @override
  State<PlacesAutocompleteScreen> createState() =>
      _PlacesAutocompleteScreenState();
}

const Duration _placesTimeout = Duration(seconds: 15);

class _PlacesAutocompleteScreenState extends State<PlacesAutocompleteScreen> {
  static String get googleApiKey => GooglePlacesAPIKey;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<Map<String, dynamic>> _predictions = [];
  bool _isLoading = false;
  bool _isFetchingLocation = true;

  GoogleMapController? _mapController;
  PlaceDetailEntity? _selectedPlace;

  CameraPosition? _initialCameraPosition;

  /// Waits for typing to pause, so Google isn't called for every letter.
  Timer? _searchDebounce;
  int _searchId = 0;

  @override
  void initState() {
    super.initState();
    _initAndFetchLocation();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// GEOLOCATOR: Automatically fetch location on screen load
  Future<void> _initAndFetchLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (serviceEnabled &&
        permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever) {
      try {
        final position = await QuickLocation.get(limit: const Duration(seconds: 3));
        if (position == null) throw StateError('No location available');

        // Open the map straight away. The address fills in a moment later, and
        // the search box and Next don't wait for it.
        if (mounted) {
          setState(() {
            _initialCameraPosition = CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 16.0,
            );
            _isFetchingLocation = false;
          });
        }

        unawaited(_reverseGeocodePosition(position.latitude, position.longitude));
      } catch (e) {
        _setFallbackLocation();
      }
    } else {
      _setFallbackLocation();
    }

    if (mounted) {
      setState(() => _isFetchingLocation = false);
    }
  }

  void _setFallbackLocation() {
    if (mounted) {
      setState(() {
        _initialCameraPosition = const CameraPosition(
          target: LatLng(20.5937, 78.9629),
          zoom: 5.0,
        );
      });
    }
  }

  /// Places API (New) — Autocomplete (SILENT FETCH)
  void _fetchSuggestions(String input) {
    _searchDebounce?.cancel();
    final id = ++_searchId;
    if (input.trim().isEmpty) {
      setState(() => _predictions = []);
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 300), () => _searchPlaces(input, id));
  }

  Future<void> _searchPlaces(String input, int id) async {

    final url = Uri.parse(
      'https://places.googleapis.com/v1/places:autocomplete',
    );

    final body = jsonEncode({
      "input": input,
      "includedRegionCodes": ["IN"],
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': googleApiKey,
        },
        body: body,
      ).timeout(_placesTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final suggestions = (data['suggestions'] as List? ?? []).map((s) {
          final place = s['placePrediction'];
          return {
            'placeId': place['placeId'] ?? '',
            'description': place['text']?['text'] ?? '',
          };
        }).toList();

        // Ignore an older answer that arrives after the partner typed more.
        if (mounted && id == _searchId) {
          setState(() => _predictions = List<Map<String, dynamic>>.from(suggestions));
        }
      }
    } catch (e) {
      log('places_autocomplete: $e');
    }
  }

  /// Places API (New) — Place Details
  Future<PlaceDetailEntity?> _fetchPlaceDetails(String placeId) async {
    setState(() => _isLoading = true);

    final url = Uri.parse('https://places.googleapis.com/v1/places/$placeId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': googleApiKey,
          'X-Goog-FieldMask': 'addressComponents,formattedAddress,location',
        },
      ).timeout(_placesTimeout);

      if (mounted) setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseAddressComponents(data);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
    return null;
  }

  PlaceDetailEntity _parseAddressComponents(Map<String, dynamic> data) {
    final components = (data['addressComponents'] as List? ?? []);
    final location = data['location'] ?? {};

    String streetNumber = '';
    String route = '';
    String sublocality = '';
    String city = '';
    String district = '';
    String state = '';
    String pinCode = '';

    for (final component in components) {
      final types = List<String>.from(component['types'] ?? []);
      final longName = (component['longText'] ?? '').toString();
      final shortName = (component['shortText'] ?? '').toString();

      if (types.contains('street_number')) {
        streetNumber = longName;
      } else if (types.contains('route')) {
        route = longName;
      } else if (types.contains('sublocality_level_1') ||
          types.contains('sublocality')) {
        sublocality = longName;
      } else if (types.contains('locality')) {
        city = longName;
      } else if (types.contains('administrative_area_level_3')) {
        district = longName;
      } else if (types.contains('administrative_area_level_2')) {
        if (district.isEmpty) district = longName;
      } else if (types.contains('administrative_area_level_1')) {
        state = longName;
      } else if (types.contains('postal_code')) {
        pinCode = shortName;
      }
    }

    final addressParts = [streetNumber, route, sublocality]
        .where((p) => p.isNotEmpty)
        .toList();
    final address = addressParts.isNotEmpty
        ? addressParts.join(', ')
        : (data['formattedAddress'] ?? '');

    return PlaceDetailEntity(
      address: address,
      city: city,
      district: district,
      state: state,
      pinCode: pinCode,
      latitude: (location['latitude'] as num?)?.toDouble(),
      longitude: (location['longitude'] as num?)?.toDouble(),
    );
  }

  /// GEOLOCATOR: Handle Manual Current Location Tap
  Future<void> _handleCurrentLocationTap() async {
    _searchFocusNode.unfocus();

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showError(L10n.current.placesServicesDisabled);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showError(L10n.current.placesPermissionDenied);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showError(L10n.current.placesPermissionDeniedForever);
      return;
    }

    setState(() => _isFetchingLocation = true);

    try {
      final position = await QuickLocation.get(limit: const Duration(seconds: 8), accuracy: LocationAccuracy.high);
      if (position == null) throw StateError('No location available');

      await _reverseGeocodePosition(position.latitude, position.longitude);

      if (mounted) {
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 16.0,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError(context.l10n.placesCurrentFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _isFetchingLocation = false);
      }
    }
  }

  /// Calls Google Geocoding API to convert LatLng to Address
  Future<void> _reverseGeocodePosition(double lat, double lng) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$googleApiKey');

    try {
      final response = await http.get(url).timeout(_placesTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK' && (data['results'] as List).isNotEmpty) {
          final result = data['results'][0];

          final detail = _parseGeocodingComponents(result, lat, lng);

          if (mounted) {
            setState(() {
              _selectedPlace = detail;
              _searchController.text = detail.address.isNotEmpty
                  ? detail.address
                  : (result['formatted_address'] ?? context.l10n.placesCurrentLocation);
              _predictions = [];
            });
          }
        }
      }
    } catch (e) {
      log('places_autocomplete: $e');
    }
  }

  PlaceDetailEntity _parseGeocodingComponents(
      Map<String, dynamic> result, double lat, double lng) {
    final components = (result['address_components'] as List? ?? []);

    String streetNumber = '';
    String route = '';
    String sublocality = '';
    String city = '';
    String district = '';
    String state = '';
    String pinCode = '';

    for (final component in components) {
      final types = List<String>.from(component['types'] ?? []);
      final longName = (component['long_name'] ?? '').toString();
      final shortName = (component['short_name'] ?? '').toString();

      if (types.contains('street_number')) {
        streetNumber = longName;
      } else if (types.contains('route')) {
        route = longName;
      } else if (types.contains('sublocality_level_1') ||
          types.contains('sublocality')) {
        sublocality = longName;
      } else if (types.contains('locality')) {
        city = longName;
      } else if (types.contains('administrative_area_level_3')) {
        district = longName;
      } else if (types.contains('administrative_area_level_2')) {
        if (district.isEmpty) district = longName;
      } else if (types.contains('administrative_area_level_1')) {
        state = longName;
      } else if (types.contains('postal_code')) {
        pinCode = shortName;
      }
    }

    final addressParts = [streetNumber, route, sublocality]
        .where((p) => p.isNotEmpty)
        .toList();
    final address = addressParts.isNotEmpty
        ? addressParts.join(', ')
        : (result['formatted_address'] ?? '');

    return PlaceDetailEntity(
      address: address,
      city: city,
      district: district,
      state: state,
      pinCode: pinCode,
      latitude: lat,
      longitude: lng,
    );
  }

  Future<void> _onSuggestionTap(Map<String, dynamic> prediction) async {
    _searchFocusNode.unfocus();

    final placeId = prediction['placeId'] as String;
    final detail = await _fetchPlaceDetails(placeId);

    if (detail != null && mounted) {
      setState(() {
        _selectedPlace = detail;
        _searchController.text = prediction['description'] ?? '';
        _predictions = [];
      });

      if (detail.latitude != null && detail.longitude != null) {
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(detail.latitude!, detail.longitude!),
              zoom: 16.0,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isScreenLoading =
        _initialCameraPosition == null || _isFetchingLocation || _isLoading;

    return CommonLoadingOverlay(
      isLoading: isScreenLoading,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppTopBar(title: context.l10n.placesAddAddress),
        body: Stack(
          children: [
            // 1. Google Map Background
            _initialCameraPosition == null
                ? const SizedBox()
                : GoogleMap(
                    initialCameraPosition: _initialCameraPosition!,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    markers: _selectedPlace?.latitude != null
                        ? {
                            Marker(
                              markerId: const MarkerId('selected-location'),
                              position: LatLng(
                                _selectedPlace!.latitude!,
                                _selectedPlace!.longitude!,
                              ),
                            ),
                          }
                        : {},
                    onMapCreated: (controller) => _mapController = controller,
                  ),

            // 2. Bottom Sheet Overlay
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.placesAddYourAddress,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Search Field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        decoration: InputDecoration(
                          hintText: context.l10n.placesSearchHint,
                          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        onChanged: _fetchSuggestions,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Current Location Button
                    InkWell(
                      onTap: _isFetchingLocation
                          ? null
                          : _handleCurrentLocationTap,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            const Icon(Icons.my_location,
                                color: AppColors.warning, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              context.l10n.placesSearchHint,
                              style: const TextStyle(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Autocomplete Predictions List (Constrained & Scrollable)
                    if (_predictions.isNotEmpty)
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 180),
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: _predictions.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final p = _predictions[index];
                            return InkWell(
                              onTap: () => _onSuggestionTap(p),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  p['description'] ?? '',
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black87),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    if (_predictions.isNotEmpty) const SizedBox(height: 16),

                    // Next Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _selectedPlace != null
                            ? () => Navigator.of(context).pop(_selectedPlace)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedPlace != null
                              ? AppColors.primary
                              : Colors.grey.shade300,
                          foregroundColor: _selectedPlace != null
                              ? Colors.white
                              : Colors.grey.shade600,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          context.l10n.commonNext,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
