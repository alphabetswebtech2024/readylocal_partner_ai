import '../../domain/entities/driver_setup_entity.dart';

class DriverServiceTypeModel extends DriverServiceTypeEntity {
  const DriverServiceTypeModel({required super.id, required super.type});
  factory DriverServiceTypeModel.fromJson(Map<String, dynamic> json) =>
      DriverServiceTypeModel(id: (json['_id'] ?? json['id'] ?? '').toString(), type: (json['Type'] ?? json['type'] ?? json['name'] ?? '').toString());
}

class DriverLicenseTypeModel extends DriverLicenseTypeEntity {
  const DriverLicenseTypeModel({required super.id, required super.type, required super.description});
  factory DriverLicenseTypeModel.fromJson(Map<String, dynamic> json) =>
      DriverLicenseTypeModel(id: (json['_id'] ?? json['id'] ?? '').toString(), type: (json['Type'] ?? json['type'] ?? json['name'] ?? '').toString(), description: (json['Description'] ?? json['description'] ?? '').toString());
}

class VehicleTypeModel extends VehicleTypeEntity {
  const VehicleTypeModel({required super.id, required super.type});
  factory VehicleTypeModel.fromJson(Map<String, dynamic> json) =>
      VehicleTypeModel(id: (json['_id'] ?? json['id'] ?? '').toString(), type: (json['Type'] ?? json['type'] ?? json['name'] ?? '').toString());
}

class SafetySkillModel extends SafetySkillEntity {
  const SafetySkillModel({required super.id, required super.skill});
  factory SafetySkillModel.fromJson(Map<String, dynamic> json) =>
      SafetySkillModel(id: (json['_id'] ?? json['id'] ?? '').toString(), skill: (json['Skill'] ?? json['skill'] ?? json['name'] ?? '').toString());
}

class DriverSetupOptionsModel extends DriverSetupOptionsEntity {
  const DriverSetupOptionsModel({
    super.serviceTypes,
    super.licenseTypes,
    super.vehicleTypes,
    super.safetySkills,
  });

  factory DriverSetupOptionsModel.fromJson(Map<String, dynamic> json) {
    return DriverSetupOptionsModel(
      serviceTypes: (json['driverServiceTypes'] as List? ?? [])
          .map((e) => DriverServiceTypeModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      licenseTypes: (json['driverLicenseTypes'] as List? ?? [])
          .map((e) => DriverLicenseTypeModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      vehicleTypes: (json['vehicleTypes'] as List? ?? [])
          .map((e) => VehicleTypeModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      safetySkills: (json['safetySkills'] as List? ?? [])
          .map((e) => SafetySkillModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
