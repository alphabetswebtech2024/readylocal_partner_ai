enum PartnerCategory {
  homeServices,
  personalCare,
  drivers,
  learningServices,
  events,
  medical,
  purohit
}

extension PartnerCategoryLabel on PartnerCategory {
  String get label {
    switch (this) {
      case PartnerCategory.homeServices:
        return 'Home Services';
      case PartnerCategory.personalCare:
        return 'Personal Care (Salon, Beauty, Mehandi)';
      case PartnerCategory.drivers:
        return 'Drivers';
      case PartnerCategory.learningServices:
        return 'Learning Services';
      case PartnerCategory.events:
        return 'Events';
      case PartnerCategory.medical:
        return 'Medical Services';
      case PartnerCategory.purohit:
        return 'Pandit / Purohit';
    }
  }
}

/// The document set for a partner's chosen service.
PartnerCategory partnerCategoryForSkills(List<dynamic> skills) {
  if (skills.isEmpty) return PartnerCategory.homeServices;
  final first = skills.first;
  final code = (first is Map ? (first['moduleName'] ?? first['moduleId'] ?? '') : '').toString().toUpperCase();
  if (code.contains('DRIVER')) return PartnerCategory.drivers;
  if (code.contains('PUROHIT') || code.contains('PANDIT')) return PartnerCategory.purohit;
  if (code.contains('PHYSIOTHERAPY') ||
      code.contains('NURSING') ||
      code.contains('CAREGIVER') ||
      code.contains('MEDICAL')) {
    return PartnerCategory.medical;
  }
  if (code.contains('PC') || code.contains('PERSONAL CARE')) return PartnerCategory.personalCare;
  return PartnerCategory.homeServices;
}
