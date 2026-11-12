import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/place_prediction_model.dart';

abstract class PlacesRemoteDataSource {
  Future<List<PlacePredictionModel>> searchPlaces(String query, String apiKey);
  Future<PlaceDetailModel> getPlaceDetails(String placeId, String apiKey);
}

class PlacesRemoteDataSourceImpl implements PlacesRemoteDataSource {
  @override
  Future<List<PlacePredictionModel>> searchPlaces(String query, String apiKey) async {
    final url = Uri.parse('https://places.googleapis.com/v1/places:autocomplete');
    final body = jsonEncode({
      "input": query,
      "includedRegionCodes": ["IN"],
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': apiKey,
      },
      body: body,
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final suggestions = (data['suggestions'] as List? ?? []).map((s) {
        final place = s['placePrediction'];
        return PlacePredictionModel(
          placeId: place['placeId'] ?? '',
          description: place['text']?['text'] ?? '',
        );
      }).toList();
      return suggestions;
    }
    throw Exception('Failed to fetch predictions');
  }

  @override
  Future<PlaceDetailModel> getPlaceDetails(String placeId, String apiKey) async {
    final url = Uri.parse('https://places.googleapis.com/v1/places/$placeId');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': apiKey,
        'X-Goog-FieldMask': 'addressComponents,formattedAddress,location',
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
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
        } else if (types.contains('sublocality_level_1') || types.contains('sublocality')) {
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

      final addressParts = [streetNumber, route, sublocality].where((p) => p.isNotEmpty).toList();
      final address = addressParts.isNotEmpty ? addressParts.join(', ') : (data['formattedAddress'] ?? '');

      return PlaceDetailModel(
        address: address,
        city: city,
        district: district,
        state: state,
        pinCode: pinCode,
        latitude: (location['latitude'] as num?)?.toDouble(),
        longitude: (location['longitude'] as num?)?.toDouble(),
      );
    }
    throw Exception('Failed to fetch place details');
  }
}
