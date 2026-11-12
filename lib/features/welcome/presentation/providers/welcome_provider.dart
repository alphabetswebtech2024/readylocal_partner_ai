import 'package:flutter/foundation.dart';
import '../../domain/entities/welcome_content_entity.dart';
import '../../domain/usecases/get_welcome_content_usecase.dart';

class WelcomeProvider extends ChangeNotifier {
  final GetWelcomeContentUseCase getWelcomeContentUseCase;

  WelcomeProvider({required this.getWelcomeContentUseCase}) {
    loadContent();
  }

  late WelcomeContentEntity _content;
  WelcomeContentEntity get content => _content;

  void loadContent() {
    _content = getWelcomeContentUseCase();
    notifyListeners();
  }
}
