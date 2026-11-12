import '../entities/web_view_config_entity.dart';
import '../repositories/app_web_view_repository.dart';

class GetWebViewConfigUseCase {
  final AppWebViewRepository repository;

  GetWebViewConfigUseCase(this.repository);

  WebViewConfigEntity call({required String title, required String url}) {
    return repository.getWebViewConfig(title: title, url: url);
  }
}
