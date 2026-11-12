import 'dart:developer';

import '../../../../core/network/api_result.dart';
import '../../domain/entities/partner_profile_data_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/partner_profile_data_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<PartnerProfileDataEntity>> getPartnerProfile(String partnerId) async {
    try {
      final rawData = await remoteDataSource.getPartnerRawDetails(partnerId);
      final rawProfile = rawData['profileDetails'] as Map<String, dynamic>? ?? rawData;
      final profile = PartnerProfileDataModel.fromJson(rawProfile);
      return ApiResult.success(profile);
    } catch (e) {
      log('Error fetching partner profile: $e');
      return ApiResult.failure(e is Exception ? e.toString() : 'Unexpected error occurred.');
    }
  }
}
