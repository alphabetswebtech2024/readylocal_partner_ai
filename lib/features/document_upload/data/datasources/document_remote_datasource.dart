import 'package:shared_preferences/shared_preferences.dart';
import 'package:gotask_partner/core/session/app_session.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/models/User.dart';
import '../../../../core/network/api_constants.dart' as api;
import '../../../../core/network/api_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/image_upload_service.dart';
import '../../domain/entities/document_urls_entity.dart';

abstract class DocumentRemoteDataSource {
  Future<String> uploadDocument(XFile file);
  Future<bool> submitDocumentsWithoutPayment({
    required User user,
    required DocumentUrlsEntity documentUrls,
    required String moduleId,
    required String moduleName,
    required dynamic professionalProfileData,
    List? skills,
  });
}

class DocumentRemoteDataSourceImpl implements DocumentRemoteDataSource {
  final ApiService _apiService;
  final AuthService _authService;

  DocumentRemoteDataSourceImpl(this._apiService)
      : _authService = AuthService(_apiService);

  @override
  Future<String> uploadDocument(XFile file) async {
    final result = await ImageUploadService.upload(file);
    if (result.isSuccess && result.url != null) {
      return result.url!;
    }
    throw Exception(result.errorMessage ?? 'Upload failed');
  }

  @override
  Future<bool> submitDocumentsWithoutPayment({
    required User user,
    required DocumentUrlsEntity documentUrls,
    required String moduleId,
    required String moduleName,
    required dynamic professionalProfileData,
    List? skills,
  }) async {
    List<dynamic>? safeProfileList;
    if (professionalProfileData != null) {
      safeProfileList = List<dynamic>.from(professionalProfileData);
    }

    final res = await _authService.updateProfile(
      partnerID: user.id,
      firstName: user.FirstName,
      lastName: user.LastName,
      gender: user.Gender,
      address: user.Address,
      city: user.City,
      state: user.State,
      district: user.District,
      pinCode: int.tryParse(user.PinCode.trim()) ?? 0,
      avatar: documentUrls.profilePic ?? user.Avatar,
      experience: user.Experience.toString(),
      upi: user.UPI,
      paymentGateWay: user.PaymentGateWay,
      refContactPerson: user.RefContactPerson,
      refContactNumber: user.RefContactNumber,
      // 6 Nov app: an empty list when a new service was chosen on this pass.
      skills: skills ?? user.skills,
      professionalProfile: safeProfileList,
      aadharPicFront: documentUrls.aadharPicFront ?? user.AadharPicFront,
      aadharPicBack: documentUrls.aadharPicBack ?? user.AadharPicBack,
      panPics: documentUrls.panPics ?? user.PanPics,
      toolPhoto: documentUrls.toolPhoto ?? user.ToolPhoto,
      addressProof: documentUrls.addressProof ?? user.AddressProof,
    );

    if (res['Status'] != 'SUCCESS' || res['StatusCode'] != 200) {
      throw Exception('Failed to update profile details');
    }


    // Save zero transaction
    final transactionRes = await _apiService.post(
      api.saveTransaction_pat,
      data: {
        'PartnerID': user.id,
        'CategoryName': 'Registration Fee',
        'TransactionID': 'FREE_REGISTRATION',
        'TransactionAmount': 0.0,
        'Remarks': 'Registration Fee - Waived',
        'TransactionMode': 'System',
        'TransactionDoneBy': 'Partner',
        'isAnyStoreService': 'false',
        'ModuleID': moduleId,
        'ModuleName': moduleName,
      },
    );

    // Saved whatever the reply, exactly as the 6 Nov app does.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('TransactionID', 'FREE_REGISTRATION');

    return transactionRes.statusCode == 200 ||
        transactionRes.statusCode == 201 ||
        transactionRes.statusCode == 202;
  }
}
