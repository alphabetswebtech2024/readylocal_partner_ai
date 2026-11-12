import '../../../../core/network/api_result.dart';
import '../entities/place_prediction_entity.dart';

abstract class PlacesRepository {
  Future<ApiResult<List<PlacePredictionEntity>>> searchPlaces(String query, String apiKey);
  Future<ApiResult<PlaceDetailEntity>> getPlaceDetails(String placeId, String apiKey);
}
