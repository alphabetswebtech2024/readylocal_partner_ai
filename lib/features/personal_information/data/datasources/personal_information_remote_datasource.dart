import 'dart:convert';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_service.dart';
import '../models/personal_info_model.dart';

abstract class PersonalInformationRemoteDataSource {
  Future<PersonalInfoModel> updateProfile(Map<String, dynamic> requestData);
}

class PersonalInformationRemoteDataSourceImpl implements PersonalInformationRemoteDataSource {
  final ApiService _apiService;

  PersonalInformationRemoteDataSourceImpl(this._apiService);

  @override
  Future<PersonalInfoModel> updateProfile(Map<String, dynamic> requestData) async {
    final response = await _apiService.post(
      '/updateProfile_pat',
      data: requestData,
    );

    final dynamic raw = response.data;
    final Map<String, dynamic> data = raw is Map<String, dynamic>
        ? raw
        : (raw is String ? jsonDecode(raw) : <String, dynamic>{});

    if (data['Status'] == 'SUCCESS') {
      return PersonalInfoModel.fromJson(data);
    }
    throw Exception(data['ResponseMsg'] ?? 'Failed to update personal information');
  }
}
