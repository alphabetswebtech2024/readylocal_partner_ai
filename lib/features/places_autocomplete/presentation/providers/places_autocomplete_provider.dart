import 'package:flutter/foundation.dart';
import '../../domain/entities/place_prediction_entity.dart';
import '../../domain/usecases/get_place_details_usecase.dart';
import '../../domain/usecases/search_places_usecase.dart';

class PlacesAutocompleteProvider extends ChangeNotifier {
  final SearchPlacesUseCase searchPlacesUseCase;
  final GetPlaceDetailsUseCase getPlaceDetailsUseCase;

  PlacesAutocompleteProvider({
    required this.searchPlacesUseCase,
    required this.getPlaceDetailsUseCase,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<PlacePredictionEntity> _predictions = [];
  List<PlacePredictionEntity> get predictions => _predictions;

  PlaceDetailEntity? _selectedPlace;
  PlaceDetailEntity? get selectedPlace => _selectedPlace;

  Future<void> search(String query, String apiKey) async {
    if (query.trim().isEmpty) {
      _predictions = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    final result = await searchPlacesUseCase(query, apiKey);
    _isLoading = false;

    result.when(
      success: (list) {
        _predictions = list;
        notifyListeners();
      },
      failure: (_) {
        _predictions = [];
        notifyListeners();
      },
    );
  }

  Future<PlaceDetailEntity?> selectPlace(String placeId, String apiKey) async {
    _isLoading = true;
    notifyListeners();

    final result = await getPlaceDetailsUseCase(placeId, apiKey);
    _isLoading = false;

    _selectedPlace = result.dataOrNull;
    notifyListeners();
    return _selectedPlace;
  }
}
