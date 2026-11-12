import '../../domain/entities/web_view_config_entity.dart';

class WebViewConfigModel extends WebViewConfigEntity {
  const WebViewConfigModel({
    required super.title,
    required super.url,
  });

  factory WebViewConfigModel.fromJson(Map<String, dynamic> json) {
    return WebViewConfigModel(
      title: json['title']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'url': url,
      };
}
