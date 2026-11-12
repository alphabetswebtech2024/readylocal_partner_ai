import '../../domain/entities/partner_profile_data_entity.dart';

class PartnerProfileDataModel extends PartnerProfileDataEntity {
  const PartnerProfileDataModel({
    super.firstName,
    super.lastName,
    super.email,
    super.gender,
    super.address,
    super.houseNo,
    super.city,
    super.state,
    super.pinCode,
  });

  factory PartnerProfileDataModel.fromJson(Map<String, dynamic> json) {
    return PartnerProfileDataModel(
      firstName: json['FirstName']?.toString() ?? '',
      lastName: json['LastName']?.toString() ?? '',
      email: json['Email']?.toString() ?? '',
      gender: json['Gender']?.toString() ?? '',
      address: json['Address']?.toString() ?? '',
      houseNo: json['HouseNo']?.toString() ?? '',
      city: json['City']?.toString() ?? '',
      state: json['State']?.toString() ?? '',
      pinCode: json['PinCode']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'FirstName': firstName,
        'LastName': lastName,
        'Email': email,
        'Gender': gender,
        'Address': address,
        'HouseNo': houseNo,
        'City': city,
        'State': state,
        'PinCode': pinCode,
      };
}
