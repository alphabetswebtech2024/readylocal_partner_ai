import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../../core/di/service_locator.dart';
import '../presentation/providers/select_categories_provider.dart';

List<SingleChildWidget> selectCategoriesProviders = [
  ChangeNotifierProvider<SelectCategoriesProvider>(
    create: (_) => ServiceLocator.createSelectCategoriesProvider(),
  ),
];
