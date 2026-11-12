import 'dart:developer';
import '../../../../core/network/api_result.dart';
import '../../domain/entities/view_profile_entity.dart';
import '../../domain/repositories/view_profile_repository.dart';
import '../datasources/view_profile_remote_datasource.dart';
import '../models/view_profile_model.dart';

class ViewProfileRepositoryImpl implements ViewProfileRepository {
  final ViewProfileRemoteDataSource remoteDataSource;

  ViewProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<ViewProfileEntity>> getViewProfileDetails(String partnerId) async {
    try {
      final rawData = await remoteDataSource.getPartnerRawDetails(partnerId);
      final rawProfile = rawData['profileDetails'] as Map<String, dynamic>? ?? rawData;
      final profile = ViewProfileModel.fromJson(rawProfile);
      return ApiResult.success(profile);
    } catch (e) {
      log('Error fetching view profile: $e');
      return ApiResult.failure(e is Exception ? e.toString() : 'Unexpected error occurred.');
    }
  }
}
