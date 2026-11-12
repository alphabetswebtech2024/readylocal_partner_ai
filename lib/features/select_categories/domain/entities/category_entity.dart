class CategoryItemEntity {
  final String id;
  final String name;
  final String? icon;

  const CategoryItemEntity({
    required this.id,
    required this.name,
    this.icon,
  });
}

class SubcategoryItemEntity {
  final String id;
  final String name;
  final String categoryId;
  final String? icon;

  const SubcategoryItemEntity({
    required this.id,
    required this.name,
    required this.categoryId,
    this.icon,
  });
}

class ServiceTypeItemEntity {
  final String id;
  final String name;
  final double defaultPrice;

  const ServiceTypeItemEntity({
    required this.id,
    required this.name,
    this.defaultPrice = 0.0,
  });
}

class ServiceItemEntity {
  final String id;
  final String name;
  final String subcategoryId;
  final double price;

  const ServiceItemEntity({
    required this.id,
    required this.name,
    required this.subcategoryId,
    this.price = 0.0,
  });
}
