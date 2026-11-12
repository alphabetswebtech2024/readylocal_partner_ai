import '../../../../core/network/api_result.dart';
import '../entities/place_prediction_entity.dart';
import '../repositories/places_repository.dart';

class SearchPlacesUseCase {
  final PlacesRepository repository;

  SearchPlacesUseCase(this.repository);

  Future<ApiResult<List<PlacePredictionEntity>>> call(String query, String apiKey) {
    return repository.searchPlaces(query, apiKey);
  }
}
