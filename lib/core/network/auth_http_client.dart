import 'package:http/http.dart' as http;
import 'token_storage.dart';

/// Endpoints that must NOT send the token
const _publicPaths = ['partnerOTP', 'partnerValidateOTP'];

class AuthHttpClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    final isPublic = _publicPaths.any((p) => request.url.path.endsWith(p));
    final token = TokenStorage.token;

    if (!isPublic && token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    return _inner.send(request);
  }
}

/// Use this everywhere instead of `http.`
final httpClient = AuthHttpClient();