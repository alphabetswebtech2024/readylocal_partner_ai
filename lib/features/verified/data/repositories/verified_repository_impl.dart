import '../../domain/entities/verified_navigation_entity.dart';
import '../../domain/repositories/verified_repository.dart';
import '../datasources/verified_local_datasource.dart';

class VerifiedRepositoryImpl implements VerifiedRepository {
  final VerifiedLocalDataSource localDataSource;

  VerifiedRepositoryImpl(this.localDataSource);

  @override
  VerifiedNavigationEntity determineDestination(bool navigateToProfile) {
    return localDataSource.getDestination(navigateToProfile);
  }
}
