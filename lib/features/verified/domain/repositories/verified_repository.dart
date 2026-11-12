import '../entities/verified_navigation_entity.dart';

abstract class VerifiedRepository {
  VerifiedNavigationEntity determineDestination(bool navigateToProfile);
}
