import 'package:flutter/foundation.dart';
import '../../domain/entities/web_view_config_entity.dart';
import '../../domain/usecases/get_web_view_config_usecase.dart';

class AppWebViewProvider extends ChangeNotifier {
  final GetWebViewConfigUseCase getWebViewConfigUseCase;

  AppWebViewProvider({required this.getWebViewConfigUseCase});

  bool _isLoading = true;
  WebViewConfigEntity? _config;

  bool get isLoading => _isLoading;
  WebViewConfigEntity? get config => _config;

  void initConfig(String title, String url) {
    _config = getWebViewConfigUseCase(title: title, url: url);
    _isLoading = true;
    notifyListeners();
  }

  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }
}
