class MedicalCategoryEntity {
  final String id;
  final String name;

  const MedicalCategoryEntity({
    required this.id,
    required this.name,
  });
}

class MedicalServiceEntity {
  final String id;
  final String name;
  final String categoryId;
  final double price;

  const MedicalServiceEntity({
    required this.id,
    required this.name,
    required this.categoryId,
    this.price = 0.0,
  });
}
