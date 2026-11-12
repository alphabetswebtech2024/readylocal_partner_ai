// The setup screens read Name, variants and SubCategoryID from these records.
// The models used to drop them, so every list row failed to draw.
import 'package:flutter_test/flutter_test.dart';
import 'package:gotask_partner/features/medical_setup/data/models/medical_setup_model.dart';
import 'package:gotask_partner/features/pandit_setup/data/models/pandit_setup_model.dart';
import 'package:gotask_partner/features/select_categories/data/models/category_model.dart';

void main() {
  const row = {
    '_id': 'a1',
    'Name': 'Split AC',
    'Code': 'SPLIT',
    'SubCategoryID': 's1',
    'has_service_types': true,
    'variants': [
      {'_id': 'v1', 'Name': 'Online'},
    ],
  };

  final all = <String, Map<String, dynamic>>{
    'category': CategoryItemModel.fromJson(row).toJson(),
    'subcategory': SubcategoryItemModel.fromJson(row).toJson(),
    'service type': ServiceTypeItemModel.fromJson(row).toJson(),
    'service': ServiceItemModel.fromJson(row).toJson(),
    'pandit category': PanditCategoryModel.fromJson(row).toJson(),
    'pandit service': PanditServiceModel.fromJson(row).toJson(),
    'medical category': MedicalCategoryModel.fromJson(row).toJson(),
    'medical service': MedicalServiceModel.fromJson(row).toJson(),
  };

  all.forEach((name, json) {
    test('$name keeps the fields its screen reads', () {
      expect(json['Name'], 'Split AC');
      expect(json['name'], 'Split AC');
      expect(json['_id'], 'a1');
      expect(json['SubCategoryID'], 's1');
      expect(json['has_service_types'], true);
      expect(json['variants'], isNotEmpty);
    });
  });

  test('old lowercase rows still work', () {
    final json = SubcategoryItemModel.fromJson(const {'_id': 'a', 'name': 'X'}).toJson();
    expect(json['Name'], 'X');
    expect(json['name'], 'X');
  });
}
