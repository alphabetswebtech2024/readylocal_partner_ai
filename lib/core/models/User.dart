class User {
  User({
    required this.id,
    required this.FirstName,
    required this.LastName,
    required this.Gender,
    required this.email,
    required this.phone,
    // ── Partner-specific fields ──────────────────────────────────────
    required this.isProfileUpdated,
    required this.isActive,
    required this.Address,
    required this.City,
    required this.State,
    required this.District,
    required this.PinCode,
    required this.Avatar,
    required this.UPI,
    required this.PaymentGateWay,
    required this.Experience,
    required this.RefContactPerson,
    required this.RefContactNumber,
    required this.skills,
    required this.AadharPicFront,
    required this.AadharPicBack,
    required this.PanPics,
    required this.ToolPhoto,
    required this.AddressProof,
    required this.QualificationCertificate,
  });

  final String id;
  final String FirstName;
  final String LastName;
  final String Gender;
  final String email;
  final String phone;

  // Partner-specific
  final bool isProfileUpdated;
  final bool isActive;
  final String Address;
  final String City;
  final String State;
  final String District;
  final String PinCode;
  final String Avatar;
  final String UPI;
  final String PaymentGateWay;
  final int Experience;
  final String RefContactPerson;
  final String RefContactNumber;
  final List skills;
  final String AadharPicFront;
  final String AadharPicBack;
  final String PanPics;
  final String ToolPhoto;
  final String AddressProof;
  final String QualificationCertificate;

  /// Resolves fields from either a top-level map or one wrapped in "UserData"
  static Map<String, dynamic> _data(Map<String, dynamic> json) =>
      json.containsKey('UserData')
          ? (json['UserData'] as Map<String, dynamic>)
          : json;

  User.fromJson(Map<String, dynamic> json)
      : id = _data(json)['_id'] ?? '',
        FirstName = _data(json)['FirstName'] ?? '',
        LastName = _data(json)['LastName'] ?? '',
        Gender = _data(json)['Gender'] ?? '',
        email = _data(json)['Email'] ?? '',
        phone = _data(json)['MobileNumber']?.toString() ?? '',
        isProfileUpdated = _data(json)['isProfileUpdated'] ?? false,
        isActive = _data(json)['isActive'] ?? true,
        Address = _data(json)['Address'] ?? '',
        City = _data(json)['City'] ?? '',
        State = _data(json)['State'] ?? '',
        District = _data(json)['District'] ?? '',
        PinCode = _data(json)['PinCode']?.toString() ?? '',
        Avatar = _data(json)['Avatar'] ?? '',
        UPI = _data(json)['UPI'] ?? '',
        PaymentGateWay = _data(json)['PaymentGateWay'] ?? '',
        Experience = _data(json)['Experience'] ?? 0,
        RefContactPerson = _data(json)['RefContactPerson'] ?? '',
        RefContactNumber = _data(json)['RefContactNumber'] ?? '',
        skills = _data(json)['skills'] ?? [],
        AadharPicFront = _data(json)['AadharPicFront'] ?? '',
        AadharPicBack = _data(json)['AadharPicBack'] ?? '',
        PanPics = _data(json)['PanPics'] ?? '',
        ToolPhoto = _data(json)['ToolPhoto'] ?? '',
        AddressProof = _data(json)['AddressProof'] ?? '',
        QualificationCertificate = _data(json)['QualificationCertificate'] ?? '';

  Map<String, dynamic> toJson() => {
        '_id': id,
        'FirstName': FirstName,
        'LastName': LastName,
        'Gender': Gender,
        'Email': email,
        'MobileNumber': phone,
        'isProfileUpdated': isProfileUpdated,
        'isActive': isActive,
        'Address': Address,
        'City': City,
        'State': State,
        'District': District,
        'PinCode': PinCode,
        'Avatar': Avatar,
        'UPI': UPI,
        'PaymentGateWay': PaymentGateWay,
        'Experience': Experience,
        'RefContactPerson': RefContactPerson,
        'RefContactNumber': RefContactNumber,
        "skills": skills,
        "AadharPicFront": AadharPicFront,
        "AadharPicBack": AadharPicBack,
        "PanPics": PanPics,
        "ToolPhoto": ToolPhoto,
        "AddressProof": AddressProof,
        "QualificationCertificate": QualificationCertificate,
      };
}