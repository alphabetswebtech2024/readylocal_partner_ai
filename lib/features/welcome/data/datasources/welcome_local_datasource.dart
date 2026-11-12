import '../models/welcome_content_model.dart';

abstract class WelcomeLocalDataSource {
  WelcomeContentModel getWelcomeContent();
}

class WelcomeLocalDataSourceImpl implements WelcomeLocalDataSource {
  @override
  WelcomeContentModel getWelcomeContent() {
    return WelcomeContentModel.fromDefaults();
  }
}
