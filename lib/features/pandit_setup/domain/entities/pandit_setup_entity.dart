class PanditCategoryEntity {
  final String id;
  final String name;

  const PanditCategoryEntity({
    required this.id,
    required this.name,
  });
}

class PanditServiceEntity {
  final String id;
  final String name;
  final String categoryId;
  final double price;

  const PanditServiceEntity({
    required this.id,
    required this.name,
    required this.categoryId,
    this.price = 0.0,
  });
}
