import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../../core/di/service_locator.dart';
import '../presentation/providers/places_autocomplete_provider.dart';

List<SingleChildWidget> placesAutocompleteProviders = [
  ChangeNotifierProvider<PlacesAutocompleteProvider>(
    create: (_) => ServiceLocator.createPlacesAutocompleteProvider(),
  ),
];
