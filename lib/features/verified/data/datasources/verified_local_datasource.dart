import '../../../../app/router/route_names.dart';
import '../models/verified_navigation_model.dart';

abstract class VerifiedLocalDataSource {
  VerifiedNavigationModel getDestination(bool navigateToProfile);
}

class VerifiedLocalDataSourceImpl implements VerifiedLocalDataSource {
  @override
  VerifiedNavigationModel getDestination(bool navigateToProfile) {
    final route = navigateToProfile ? AppRoutes.personalInfo : AppRoutes.home;
    return VerifiedNavigationModel.create(
      navigateToProfile: navigateToProfile,
      route: route,
    );
  }
}
