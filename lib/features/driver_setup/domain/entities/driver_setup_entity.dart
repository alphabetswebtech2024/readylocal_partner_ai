class DriverServiceTypeEntity {
  final String id;
  final String type;

  const DriverServiceTypeEntity({
    required this.id,
    required this.type,
  });
}

class DriverLicenseTypeEntity {
  final String id;
  final String type;
  final String description;

  const DriverLicenseTypeEntity({
    required this.id,
    required this.type,
    required this.description,
  });
}

class VehicleTypeEntity {
  final String id;
  final String type;

  const VehicleTypeEntity({
    required this.id,
    required this.type,
  });
}

class SafetySkillEntity {
  final String id;
  final String skill;

  const SafetySkillEntity({
    required this.id,
    required this.skill,
  });
}

class DriverSetupOptionsEntity {
  final List<DriverServiceTypeEntity> serviceTypes;
  final List<DriverLicenseTypeEntity> licenseTypes;
  final List<VehicleTypeEntity> vehicleTypes;
  final List<SafetySkillEntity> safetySkills;

  const DriverSetupOptionsEntity({
    this.serviceTypes = const [],
    this.licenseTypes = const [],
    this.vehicleTypes = const [],
    this.safetySkills = const [],
  });
}
