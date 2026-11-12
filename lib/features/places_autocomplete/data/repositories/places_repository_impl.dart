import '../../../../core/network/api_result.dart';
import '../../domain/entities/place_prediction_entity.dart';
import '../../domain/repositories/places_repository.dart';
import '../datasources/places_remote_datasource.dart';

class PlacesRepositoryImpl implements PlacesRepository {
  final PlacesRemoteDataSource remoteDataSource;

  PlacesRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<List<PlacePredictionEntity>>> searchPlaces(String query, String apiKey) async {
    try {
      final list = await remoteDataSource.searchPlaces(query, apiKey);
      return ApiResult.success(list);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  @override
  Future<ApiResult<PlaceDetailEntity>> getPlaceDetails(String placeId, String apiKey) async {
    try {
      final detail = await remoteDataSource.getPlaceDetails(placeId, apiKey);
      return ApiResult.success(detail);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }
}
