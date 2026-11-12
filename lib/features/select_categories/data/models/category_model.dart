import '../../../../core/network/api_rows.dart';
import '../../domain/entities/category_entity.dart';

class CategoryItemModel extends CategoryItemEntity {
  const CategoryItemModel({
    required super.id,
    required super.name,
    super.icon,
    this.raw,
  });

  /// The full server record. The setup screens read fields such as Name,
  /// variants and SubCategoryID directly, so they must not be dropped.
  final Map<String, dynamic>? raw;

  factory CategoryItemModel.fromJson(Map<String, dynamic> json) {
    return CategoryItemModel(
      raw: json,
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['Name'] ?? json['name'] ?? json['categoryName'] ?? '').toString(),
      icon: (json['Icon'] ?? json['icon'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    ...?raw,
    'Name': raw?['Name'] ?? name,
    '_id': id,
    'id': id,
    'name': name,
    'categoryName': name,
    if (icon != null) 'icon': icon,
  };
}

class SubcategoryItemModel extends SubcategoryItemEntity {
  const SubcategoryItemModel({
    required super.id,
    required super.name,
    required super.categoryId,
    super.icon,
    this.raw,
  });

  /// The full server record. The setup screens read fields such as Name,
  /// variants and SubCategoryID directly, so they must not be dropped.
  final Map<String, dynamic>? raw;

  factory SubcategoryItemModel.fromJson(Map<String, dynamic> json) {
    return SubcategoryItemModel(
      raw: json,
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['Name'] ?? json['name'] ?? json['subCategoryName'] ?? '').toString(),
      categoryId: (json['CategoryID'] ?? json['categoryId'] ?? '').toString(),
      icon: (json['Icon'] ?? json['icon'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    ...?raw,
    'Name': raw?['Name'] ?? name,
    '_id': id,
    'id': id,
    'name': name,
    'subCategoryName': name,
    'categoryId': categoryId,
    if (icon != null) 'icon': icon,
  };
}

class ServiceTypeItemModel extends ServiceTypeItemEntity {
  const ServiceTypeItemModel({
    required super.id,
    required super.name,
    super.defaultPrice,
    this.raw,
  });

  /// The full server record. The setup screens read fields such as Name,
  /// variants and SubCategoryID directly, so they must not be dropped.
  final Map<String, dynamic>? raw;

  factory ServiceTypeItemModel.fromJson(Map<String, dynamic> json) {
    return ServiceTypeItemModel(
      raw: json,
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['Name'] ?? json['name'] ?? json['serviceTypeName'] ?? '').toString(),
      defaultPrice: numberOf(json['defaultPrice']),
    );
  }

  Map<String, dynamic> toJson() => {
    ...?raw,
    'Name': raw?['Name'] ?? name,
    '_id': id,
    'id': id,
    'name': name,
    'serviceTypeName': name,
    'defaultPrice': defaultPrice,
  };
}

class ServiceItemModel extends ServiceItemEntity {
  const ServiceItemModel({
    required super.id,
    required super.name,
    required super.subcategoryId,
    super.price,
    this.raw,
  });

  /// The full server record. The setup screens read fields such as Name,
  /// variants and SubCategoryID directly, so they must not be dropped.
  final Map<String, dynamic>? raw;

  factory ServiceItemModel.fromJson(Map<String, dynamic> json) {
    return ServiceItemModel(
      raw: json,
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['Name'] ?? json['name'] ?? json['serviceName'] ?? '').toString(),
      subcategoryId: (json['SubCategoryID'] ?? json['subCategoryId'] ?? json['subcategoryId'] ?? '').toString(),
      price: numberOf(json['price']),
    );
  }

  Map<String, dynamic> toJson() => {
    ...?raw,
    'Name': raw?['Name'] ?? name,
    '_id': id,
    'id': id,
    'name': name,
    'serviceName': name,
    'subCategoryId': subcategoryId,
    'price': price,
  };
}
