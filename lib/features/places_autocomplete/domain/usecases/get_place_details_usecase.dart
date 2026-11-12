import '../../../../core/network/api_result.dart';
import '../entities/place_prediction_entity.dart';
import '../repositories/places_repository.dart';

class GetPlaceDetailsUseCase {
  final PlacesRepository repository;

  GetPlaceDetailsUseCase(this.repository);

  Future<ApiResult<PlaceDetailEntity>> call(String placeId, String apiKey) {
    return repository.getPlaceDetails(placeId, apiKey);
  }
}
