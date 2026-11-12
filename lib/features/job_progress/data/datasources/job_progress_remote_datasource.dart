import 'dart:convert';
import '../../../../core/network/api_constants.dart' as api;
import '../../../../core/network/api_service.dart';
import 'package:gotask_partner/core/network/api_response_check.dart';
import 'package:dio/dio.dart';
import 'package:gotask_partner/core/services/image_upload_service.dart';

abstract class JobProgressRemoteDataSource {
  Future<String> uploadWorkImage({
    required String filename,
    required String base64Data,
  });

  Future<bool> cancelJob({
    required String partnerId,
    required String jobId,
    required String reason,
  });

  Future<bool> completeJob({
    required String partnerId,
    required String jobId,
    required List<String> workPicUrls,
    required String reason,
  });
}

class JobProgressRemoteDataSourceImpl implements JobProgressRemoteDataSource {
  final ApiService _apiService;

  JobProgressRemoteDataSourceImpl(this._apiService);

  @override
  Future<String> uploadWorkImage({
    required String filename,
    required String base64Data,
  }) async {
    // A weak signal often drops one attempt; try again twice before showing an error.
    for (var attempt = 0;; attempt++) {
      try {
        return await _uploadOnce(filename: filename, base64Data: base64Data);
      } on DioException catch (e) {
        if (e.response != null || attempt >= 2) rethrow;
        await Future<void>.delayed(Duration(seconds: 2 * (attempt + 1)));
      }
    }
  }

  Future<String> _uploadOnce({
    required String filename,
    required String base64Data,
  }) async {
    // The app's two upload paths used different field names for this same
    // endpoint (fileName/fileData here, filename/filedata for documents), and
    // only one can match the server. Try the other only if the first is refused.
    for (final keys in const [
      ['fileName', 'fileData'],
      ['filename', 'filedata'],
    ]) {
      try {
        final response = await _apiService.post(
          api.uploadToS3,
          data: jsonEncode({keys[0]: filename, keys[1]: base64Data}),
        );
        final path = ImageUploadService.uploadedPath(response.data);
        if (path != null) return path;
      } on DioException catch (e) {
        // Only a refused request is worth repeating; a network failure isn't.
        if (e.response == null) rethrow;
      }
    }
    throw Exception('Failed to upload image: No URL returned');
  }

  @override
  Future<bool> cancelJob({
    required String partnerId,
    required String jobId,
    required String reason,
  }) async {
    final response = await _apiService.post(
      api.cancelledJob,
      data: jsonEncode({
        "partnerId": partnerId,
        "JobId": jobId,
        "jobId": jobId,
        "reason": reason,
        "isCustomerAvailable": "No",
        "Review": reason,
      }),
    );

    return apiCallSucceeded(response);
  }

  @override
  Future<bool> completeJob({
    required String partnerId,
    required String jobId,
    required List<String> workPicUrls,
    required String reason,
  }) async {
    final response = await _apiService.post(
      api.completedJob,
      data: jsonEncode({
        "partnerId": partnerId,
        "jobId": jobId,
        "JobId": jobId,
        "WorkPic": workPicUrls,
        "WorkPics": [for (final url in workPicUrls) {"pic": url}],
        "reason": reason, // same field name as cancelledJob
        "isCustomerAvailable": "Yes",
      }),
    );

    return apiCallSucceeded(response);
  }
}
