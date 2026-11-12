class ServiceModuleEntity {
  final String id;
  final String title;
  final String moduleCode;
  final String? image;
  final bool hasCategory;

  const ServiceModuleEntity({
    required this.id,
    required this.title,
    required this.moduleCode,
    this.image,
    this.hasCategory = false,
  });
}
