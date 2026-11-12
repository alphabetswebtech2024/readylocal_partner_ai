import '../../domain/entities/verified_navigation_entity.dart';

class VerifiedNavigationModel extends VerifiedNavigationEntity {
  const VerifiedNavigationModel({
    required super.navigateToProfile,
    required super.destinationRoute,
  });

  factory VerifiedNavigationModel.create({required bool navigateToProfile, required String route}) {
    return VerifiedNavigationModel(
      navigateToProfile: navigateToProfile,
      destinationRoute: route,
    );
  }
}
