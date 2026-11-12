import '../../domain/entities/service_module_entity.dart';

class ServiceModuleModel extends ServiceModuleEntity {
  const ServiceModuleModel({
    required super.id,
    required super.title,
    required super.moduleCode,
    super.image,
    super.hasCategory,
  });

  factory ServiceModuleModel.fromJson(Map<String, dynamic> json) {
    return ServiceModuleModel(
      id: (json['_id'] ?? '').toString(),
      title: (json['Name'] ?? '').toString(),
      moduleCode: (json['Code'] ?? '').toString(),
      image: json['Icon']?.toString(),
      hasCategory: json['has_category'] == true,
    );
  }
}
