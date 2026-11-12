import 'dart:developer' as developer;
import '../network/api_constants.dart';
import '../network/api_service.dart';

class AuthService {
  final ApiService _api;

  AuthService(this._api);

  /// ── Send OTP ─────────────────────────────────────────
  Future<Map<String, dynamic>> sendOtp(String mobileNumber) async {
    final response = await _api.post(
      ApiConstants.partnerOtp,
      data: {'MobileNumber': mobileNumber},
    );
    developer.log("sendOtp response: ${response.data}");
    return response.data as Map<String, dynamic>;
  }

  /// ── Validate OTP ─────────────────────────────────────
  Future<Map<String, dynamic>> validateOtp({
    required String mobileNumber,
    required String otp,
  }) async {
    final response = await _api.post(
      ApiConstants.partnerValidateOtp,
      data: {
        'MobileNumber': mobileNumber,
        'OTP': otp,
      },
    );
    developer.log("validateOtp response: ${response.data}");
    return response.data as Map<String, dynamic>;
  }

  /// ── Update Profile ───────────────────────────────────
  Future<Map<String, dynamic>> updateProfile({
    required String partnerID,
    required String firstName,
    required String lastName,
    required String gender,
    required String address,
    required String city,
    required String state,
    required String district,
    required int pinCode,
    String avatar = '',
    List skills = const [],
    List<dynamic>? professionalProfile,
    String experience = '',
    String aadharPicFront = '',
    String aadharPicBack = '',
    String panPics = '',
    String toolPhoto = '',
    String addressProof = '',
    String drivingLicense = '',
    String paymentGateWay = '',
    String upi = '',
    String refContactPerson = '',
    String refContactNumber = '',
  }) async {
    final Map<String, dynamic> requestData = {
      'partnerID': partnerID,
      'FirstName': firstName,
      'LastName': lastName,
      'Gender': gender,
      'Address': address,
      'City': city,
      'State': state,
      'District': district,
      'PinCode': pinCode,
      'Avatar': avatar,
      'skills': skills,
      'Experience': experience,
      'AadharPicFront': aadharPicFront,
      'AadharPicBack': aadharPicBack,
      'PanPics': panPics,
      'ToolPhoto': toolPhoto,
      'AddressProof': addressProof,
      'DrivingLicense': drivingLicense,
      'PaymentGateWay': paymentGateWay,
      'UPI': upi,
      'RefContactPerson': refContactPerson,
      'RefContactNumber': refContactNumber,
    };

    if (professionalProfile != null && professionalProfile.isNotEmpty) {
      requestData['professionalProfile'] = professionalProfile;
    }

    final response = await _api.post(
      '/updateProfile_pat',
      data: requestData,
    );

    return response.data as Map<String, dynamic>;
  }
}