import '../../domain/entities/web_view_config_entity.dart';
import '../../domain/repositories/app_web_view_repository.dart';
import '../datasources/app_web_view_local_datasource.dart';

class AppWebViewRepositoryImpl implements AppWebViewRepository {
  final AppWebViewLocalDataSource localDataSource;

  AppWebViewRepositoryImpl(this.localDataSource);

  @override
  WebViewConfigEntity getWebViewConfig({required String title, required String url}) {
    return localDataSource.getConfig(title: title, url: url);
  }
}
