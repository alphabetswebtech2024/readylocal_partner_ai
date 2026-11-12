import '../../domain/entities/welcome_content_entity.dart';

class WelcomeContentModel extends WelcomeContentEntity {
  const WelcomeContentModel({super.logoPath, super.title, super.subtitle});

  factory WelcomeContentModel.fromDefaults() {
    return const WelcomeContentModel();
  }
}
