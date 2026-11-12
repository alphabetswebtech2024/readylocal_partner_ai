import '../../domain/entities/place_prediction_entity.dart';

class PlacePredictionModel extends PlacePredictionEntity {
  const PlacePredictionModel({
    required super.description,
    required super.placeId,
  });

  factory PlacePredictionModel.fromJson(Map<String, dynamic> json) {
    return PlacePredictionModel(
      description: json['description'] ?? '',
      placeId: json['place_id'] ?? '',
    );
  }
}

class PlaceDetailModel extends PlaceDetailEntity {
  const PlaceDetailModel({
    required super.address,
    required super.city,
    required super.district,
    required super.state,
    required super.pinCode,
    super.latitude,
    super.longitude,
  });

  factory PlaceDetailModel.fromJson(Map<String, dynamic> result) {
    final components = result['address_components'] as List<dynamic>? ?? [];
    String city = '';
    String district = '';
    String state = '';
    String pinCode = '';

    for (var component in components) {
      final types = List<String>.from(component['types'] ?? []);
      if (types.contains('locality')) {
        city = component['long_name'] ?? '';
      }
      if (types.contains('administrative_area_level_2')) {
        district = component['long_name'] ?? '';
      }
      if (types.contains('administrative_area_level_1')) {
        state = component['long_name'] ?? '';
      }
      if (types.contains('postal_code')) {
        pinCode = component['long_name'] ?? '';
      }
    }

    final location = result['geometry']?['location'];
    final lat = location != null ? (location['lat'] as num?)?.toDouble() : null;
    final lng = location != null ? (location['lng'] as num?)?.toDouble() : null;

    return PlaceDetailModel(
      address: result['formatted_address'] ?? '',
      city: city,
      district: district,
      state: state,
      pinCode: pinCode,
      latitude: lat,
      longitude: lng,
    );
  }
}
