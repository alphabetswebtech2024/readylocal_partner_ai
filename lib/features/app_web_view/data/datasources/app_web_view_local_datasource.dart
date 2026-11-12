import '../models/web_view_config_model.dart';

abstract class AppWebViewLocalDataSource {
  WebViewConfigModel getConfig({required String title, required String url});
}

class AppWebViewLocalDataSourceImpl implements AppWebViewLocalDataSource {
  @override
  WebViewConfigModel getConfig({required String title, required String url}) {
    return WebViewConfigModel(title: title, url: url);
  }
}
