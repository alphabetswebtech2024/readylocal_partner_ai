import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import '../network/token_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../network/api_constants.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';

/// The result of uploading a single image to the partner API.
class ImageUploadResult {
  const ImageUploadResult._({this.url, this.errorMessage, this.isNetworkFailure = false});

  final String? url;
  final String? errorMessage;

  /// Timed out or lost the connection: worth trying again.
  final bool isNetworkFailure;

  bool get isSuccess => url != null && url!.isNotEmpty;

  factory ImageUploadResult.success(String url) => ImageUploadResult._(url: url);

  factory ImageUploadResult.failure(String errorMessage, {bool networkFailure = false}) =>
      ImageUploadResult._(errorMessage: errorMessage, isNetworkFailure: networkFailure);
}

/// Uploads images safely to the existing base64 upload endpoint.
///
/// The endpoint accepts a JSON/base64 payload, so accepting an unbounded camera
/// file can otherwise create several large in-memory copies on low-memory devices.
class ImageUploadService {
  ImageUploadService._();

  static const int maxImageBytes = 10 * 1024 * 1024;
  static const Duration _requestTimeout = Duration(seconds: 60);

  static Future<String?> validate(XFile file) async {
    try {
      final length = await file.length();
      if (length == 0) return L10n.current.imgEmpty;
      if (length > maxImageBytes) {
        return L10n.current.imgTooLarge;
      }
      return null;
    } on FileSystemException {
      return L10n.current.imgUnavailable;
    }
  }

  /// Reads the stored file's address from an upload response. The two old
  /// callers each looked for one name only (`filePath` / `location`).
  static String? uploadedPath(dynamic body) {
    if (body is! Map) return null;
    final status = body['Status'];
    if (status is String && status.toUpperCase() == 'FAILED') return null;
    final data = body['Data'];
    for (final source in [body, if (data is Map) data]) {
      for (final key in const ['filePath', 'location', 'url', 'Location']) {
        final value = source[key]?.toString();
        if (value != null && value.isNotEmpty) return value;
      }
    }
    return null;
  }

  /// Uploads with up to two automatic retries when the network drops or times
  /// out, so a weak signal does not make the partner upload the photo again.
  static Future<ImageUploadResult> upload(XFile image) async {
    ImageUploadResult result = await _uploadOnce(image);
    for (var attempt = 1; attempt <= 2 && result.isNetworkFailure; attempt++) {
      await Future<void>.delayed(Duration(seconds: 2 * attempt));
      result = await _uploadOnce(image);
    }
    return result;
  }

  static Future<ImageUploadResult> _uploadOnce(XFile image) async {
    final validationError = await validate(image);
    if (validationError != null) return ImageUploadResult.failure(validationError);

    try {
      // Encoding the file stream avoids holding both the original byte list and
      // its base64 representation in memory at the same time.
      final base64Data = await base64.encoder.bind(image.openRead()).join();
      // uploadToS3 rejects requests without a login (HTTP 401, checked against
      // the live server). This call never sent the token, so document uploads
      // could not succeed.
      final token = TokenStorage.token;
      final headers = {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };
      var failed = true;
      for (final keys in const [
        ['filename', 'filedata'],
        ['fileName', 'fileData'],
      ]) {
        final response = await http
            .post(
              Uri.parse(uploadToS3),
              headers: headers,
              body: jsonEncode({keys[0]: image.name, keys[1]: base64Data}),
            )
            .timeout(_requestTimeout);
        if (response.statusCode == HttpStatus.ok) failed = false;
        if (response.statusCode == HttpStatus.ok || response.statusCode == HttpStatus.badRequest) {
          final path = uploadedPath(jsonDecode(response.body));
          if (path != null) return ImageUploadResult.success(path);
        }
      }
      return ImageUploadResult.failure(failed ? L10n.current.imgServerFailed : L10n.current.imgInvalidResponse);
    } on TimeoutException {
      return ImageUploadResult.failure(L10n.current.imgTimeout, networkFailure: true);
    } on SocketException {
      return ImageUploadResult.failure(L10n.current.imgOffline, networkFailure: true);
    } on http.ClientException {
      return ImageUploadResult.failure(L10n.current.imgOffline, networkFailure: true);
    } on FileSystemException {
      return ImageUploadResult.failure(L10n.current.imgUnavailable);
    } on FormatException {
      return ImageUploadResult.failure(L10n.current.imgInvalidResponse);
    } catch (_) {
      return ImageUploadResult.failure(L10n.current.imgUploadFailed);
    }
  }
}
