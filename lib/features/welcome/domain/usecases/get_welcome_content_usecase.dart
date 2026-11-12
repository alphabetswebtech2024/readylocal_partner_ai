import '../entities/welcome_content_entity.dart';
import '../repositories/welcome_repository.dart';

class GetWelcomeContentUseCase {
  final WelcomeRepository repository;

  GetWelcomeContentUseCase(this.repository);

  WelcomeContentEntity call() {
    return repository.getWelcomeContent();
  }
}
