import '../entities/verified_navigation_entity.dart';
import '../repositories/verified_repository.dart';

class GetVerifiedDestinationUseCase {
  final VerifiedRepository repository;

  GetVerifiedDestinationUseCase(this.repository);

  VerifiedNavigationEntity call(bool navigateToProfile) {
    return repository.determineDestination(navigateToProfile);
  }
}
