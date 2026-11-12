import '../entities/web_view_config_entity.dart';

abstract class AppWebViewRepository {
  WebViewConfigEntity getWebViewConfig({required String title, required String url});
}
