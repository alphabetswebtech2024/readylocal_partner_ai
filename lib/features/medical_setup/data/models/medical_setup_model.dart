import '../../../../core/network/api_rows.dart';
import '../../domain/entities/medical_setup_entity.dart';

class MedicalCategoryModel extends MedicalCategoryEntity {
  const MedicalCategoryModel({required super.id, required super.name, this.raw});

  /// The full server record. The setup screens read fields such as Name,
  /// variants and SubCategoryID directly, so they must not be dropped.
  final Map<String, dynamic>? raw;

  factory MedicalCategoryModel.fromJson(Map<String, dynamic> json) =>
      MedicalCategoryModel(
        raw: json,
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        name: (json['Name'] ?? json['name'] ?? json['categoryName'] ?? '').toString(),
      );

  Map<String, dynamic> toJson() => {
    ...?raw,
    'Name': raw?['Name'] ?? name,
    '_id': id,
    'id': id,
    'name': name,
    'categoryName': name,
  };
}

class MedicalServiceModel extends MedicalServiceEntity {
  const MedicalServiceModel({
    required super.id,
    required super.name,
    required super.categoryId,
    super.price,
    this.raw,
  });

  /// The full server record. The setup screens read fields such as Name,
  /// variants and SubCategoryID directly, so they must not be dropped.
  final Map<String, dynamic>? raw;

  factory MedicalServiceModel.fromJson(Map<String, dynamic> json) =>
      MedicalServiceModel(
        raw: json,
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        name: (json['Name'] ?? json['name'] ?? json['serviceName'] ?? '').toString(),
        categoryId: (json['CategoryID'] ?? json['categoryId'] ?? json['subcategoryId'] ?? '').toString(),
        price: numberOf(json['price']),
      );

  Map<String, dynamic> toJson() => {
    ...?raw,
    'Name': raw?['Name'] ?? name,
    '_id': id,
    'id': id,
    'name': name,
    'serviceName': name,
    'categoryId': categoryId,
    'price': price,
  };
}
