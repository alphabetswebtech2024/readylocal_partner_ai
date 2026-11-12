class ViewProfileEntity {
  final String firstName;
  final String lastName;
  final String email;
  final String gender;
  final String address;
  final String houseNo;
  final String city;
  final String state;
  final String pinCode;

  const ViewProfileEntity({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.gender = '',
    this.address = '',
    this.houseNo = '',
    this.city = '',
    this.state = '',
    this.pinCode = '',
  });

  String get fullName => '$firstName $lastName'.trim();
}
