class PlacePredictionEntity {
  final String description;
  final String placeId;

  const PlacePredictionEntity({
    required this.description,
    required this.placeId,
  });
}

class PlaceDetailEntity {
  final String address;
  final String city;
  final String district;
  final String state;
  final String pinCode;
  final double? latitude;
  final double? longitude;

  const PlaceDetailEntity({
    required this.address,
    required this.city,
    required this.district,
    required this.state,
    required this.pinCode,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() => {
    'address': address,
    'city': city,
    'district': district,
    'state': state,
    'pinCode': pinCode,
    'latitude': latitude,
    'longitude': longitude,
  };

  dynamic operator [](String key) {
    switch (key) {
      case 'address':
        return address;
      case 'city':
        return city;
      case 'district':
        return district;
      case 'state':
        return state;
      case 'pinCode':
        return pinCode;
      case 'latitude':
        return latitude;
      case 'longitude':
        return longitude;
      default:
        return null;
    }
  }
}
