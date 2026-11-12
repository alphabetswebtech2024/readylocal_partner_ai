import '../../domain/entities/welcome_content_entity.dart';
import '../../domain/repositories/welcome_repository.dart';
import '../datasources/welcome_local_datasource.dart';

class WelcomeRepositoryImpl implements WelcomeRepository {
  final WelcomeLocalDataSource localDataSource;

  WelcomeRepositoryImpl(this.localDataSource);

  @override
  WelcomeContentEntity getWelcomeContent() {
    return localDataSource.getWelcomeContent();
  }
}
