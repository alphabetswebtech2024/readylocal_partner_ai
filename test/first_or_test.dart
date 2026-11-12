import 'package:flutter_test/flutter_test.dart';
import 'package:gotask_partner/core/utils/first_or.dart';
import 'package:gotask_partner/features/driver_setup/data/models/driver_setup_model.dart';
import 'package:gotask_partner/features/driver_setup/domain/entities/driver_setup_entity.dart';

void main() {
  // The real options parse into model subclasses behind entity-typed lists.
  final options = DriverSetupOptionsModel.fromJson(const {
    'driverServiceTypes': [
      {'_id': 'd1', 'type': 'Hourly'},
    ],
  });
  const fallback = DriverServiceTypeEntity(id: '', type: 'Unknown');

  test('finds a match in the real parsed list (firstWhere with orElse threw here)', () {
    expect(firstOr(options.serviceTypes, (e) => e.id == 'd1', fallback).type, 'Hourly');
  });

  test('returns the fallback when nothing matches', () {
    expect(firstOr(options.serviceTypes, (e) => e.id == 'x', fallback).type, 'Unknown');
  });
}
