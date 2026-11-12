// lib/core/network/api_client.dart

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:math' show Random;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

import '../localization/locale_provider.dart';
import 'api_constants.dart';
import 'auth_interceptor.dart';
import 'token_storage.dart';

/// Centralized Dio client with:
/// - Base URL & timeouts
/// - Request/response logging interceptor
/// - Connectivity-aware error interceptor
/// - Typed ApiException with user-friendly messages
class ApiClient {
  static final String _baseUrl = baseUrl;

  static const Duration _connectTimeout = Duration(seconds: 10);
  static const Duration _receiveTimeout = Duration(seconds: 30);

  late final Dio _dio;
  StreamSubscription<List<ConnectivityResult>>? _networkChanges;

  /// Sockets idle out quickly, so a Wi-Fi/mobile switch doesn't reuse a dead one.
  static HttpClientAdapter _newAdapter() => IOHttpClientAdapter(
        createHttpClient: () => HttpClient()
          ..idleTimeout = const Duration(seconds: 15)
          ..maxConnectionsPerHost = 8,
      );

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: _connectTimeout,
        receiveTimeout: _receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.httpClientAdapter = _newAdapter();

    _dio.interceptors.addAll([
      AuthInterceptor(),
      // Request/response logging prints bodies and the auth header, so it is
      // only added in debug builds; release builds never write them to logcat.
      if (kDebugMode) LogInterceptor(),
      if (kDebugMode) _LoggingInterceptor(),
      RetryReadsInterceptor(_dio),
      _ErrorInterceptor(),
    ]);
  }

  /// When the phone switches between Wi-Fi and mobile data, open sockets are
  /// dead but look alive until a timeout. Starting a fresh connection pool
  /// makes the next request go straight out on the new network.
  /// Called once from main() after startup.
  void watchNetworkChanges() {
    if (_networkChanges != null) return;
    try {
      _networkChanges = Connectivity().onConnectivityChanged.skip(1).listen((_) {
        if (_dio.httpClientAdapter is! IOHttpClientAdapter) return;
        final old = _dio.httpClientAdapter;
        _dio.httpClientAdapter = _newAdapter();
        old.close();
      }, onError: (_) {});
    } catch (_) {
      // No connectivity plugin available (tests); nothing to do.
    }
  }

  void dispose() => _networkChanges?.cancel();

  Dio get dio => _dio;

  /// Call after login. Saves to SharedPreferences; the interceptor
  /// attaches it to every request automatically.
  Future<void> setAuthToken(String token) => TokenStorage.save(token);

  Future<void> clearAuthToken() => TokenStorage.clear();
}

// ─── Logging Interceptor ─────────────────────────────────────────────────────

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log('┌── [${options.method}] ${options.uri}');
    if (options.data != null) debugPrint('│  Body: ${options.data}');
    log('│  Headers: ${options.headers}');
    log('└─────────────────────────────');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log('┌── RESPONSE [${response.statusCode}] ${response.requestOptions.uri}');
    log('│  ${response.data}');
    log('└─────────────────────────────');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log('┌── ERROR [${err.response?.statusCode}] ${err.requestOptions.uri}');
    log('│  ${err.message}');
    log('└─────────────────────────────');
    handler.next(err);
  }
}

// ─── Retry Interceptor ───────────────────────────────────────────────────────

/// Quietly retries read-only calls that fail because of the network or a busy
/// server, so a brief drop doesn't show the partner an error.
///
/// Only the listed endpoints are retried: they just fetch data. Anything that
/// changes data (accept, complete, withdraw, payment, OTP, ...) is never
/// retried automatically, so it can't happen twice. The random delay stops
/// many phones retrying at the same moment when the server is under load.
class RetryReadsInterceptor extends Interceptor {
  RetryReadsInterceptor(this._dio, {Random? random, this.baseDelay = const Duration(milliseconds: 500)})
      : _random = random ?? Random();

  final Dio _dio;
  final Random _random;
  final Duration baseDelay;

  static const int maxRetries = 2;

  static const Set<String> readOnlyEndpoints = {
    'getModules',
    'getCategories',
    'getSubCategoriesNew',
    'getServiceTypesNew',
    'getServicesNew',
    'getRequestDetails_pat',
    'getVehicleTypes',
    'getSafetySkills',
    'getDriverServiceTypes',
    'getDriverLicenseTypes',
    'getPartnerDetails',
    'getPurohitServices',
    'getPersonalCareServices',
    'getEarningsSummary',
    'getEarningDetails',
    'getTransactionDetails',
    'listBankAccounts',
  };

  static bool isReadOnly(RequestOptions options) {
    final path = options.uri.path;
    return readOnlyEndpoints.contains(path.substring(path.lastIndexOf('/') + 1));
  }

  static bool isTemporary(DioException e) {
    switch (e.type) {
      // Not timeouts: repeating a 30-second wait could keep a screen loading for
      // over a minute. Only failures that come back quickly are retried.
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        return const {429, 502, 503}.contains(e.response?.statusCode);
      case DioExceptionType.unknown:
        return e.error is SocketException || e.error is HttpException || e.error is HandshakeException;
      default:
        return false;
    }
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final attempt = options.extra['retryAttempt'] as int? ?? 0;
    if (attempt >= maxRetries || !isReadOnly(options) || !isTemporary(err)) {
      handler.next(err);
      return;
    }
    await Future<void>.delayed(baseDelay * (attempt + 1) + Duration(milliseconds: _random.nextInt(400)));
    options.extra['retryAttempt'] = attempt + 1;
    try {
      handler.resolve(await _dio.fetch<dynamic>(options));
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}

// ─── Error Interceptor ────────────────────────────────────────────────────────

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: ApiException.fromDioException(err),
      ),
    );
  }
}

// ─── Typed ApiException ───────────────────────────────────────────────────────

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  factory ApiException.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(L10n.current.netTimeout);
      case DioExceptionType.connectionError:
        return ApiException(L10n.current.netNoInternet);
      case DioExceptionType.badResponse:
        return ApiException._fromResponse(e.response!);
      case DioExceptionType.cancel:
        return ApiException(L10n.current.netCancelled);
      default:
        // Never show raw technical text such as "SocketException: ..." to a partner.
        final cause = e.error;
        if (cause is SocketException || cause is HttpException || cause is HandshakeException) {
          return ApiException(L10n.current.netNoInternet);
        }
        return ApiException(L10n.current.netUnexpected);
    }
  }

  factory ApiException._fromResponse(Response response) {
    final code = response.statusCode ?? 0;
    final data = response.data;

    // Try to extract server-provided message
    String? serverMessage;
    if (data is Map) {
      // Any of these can be a non-string on a bad response; a failed cast here
      // would replace the real error with a crash.
      String? textOf(dynamic v) => v is String && v.trim().isNotEmpty ? v : null;
      final errors = data['errors'];
      final firstError = errors is List && errors.isNotEmpty ? errors.first : null;
      serverMessage = textOf(data['Message']) ??
          textOf(data['message']) ??
          (firstError is Map ? textOf(firstError['title']) : null) ??
          textOf(data['error']);
    }

    final l10n = L10n.current;
    final fallback = switch (code) {
      400 => l10n.net400,
      401 => l10n.net401,
      403 => l10n.net403,
      404 => l10n.net404,
      422 => l10n.net422,
      429 => l10n.net429,
      500 => l10n.net500,
      503 => l10n.net503,
      _ => l10n.netCode(code),
    };

    return ApiException(serverMessage ?? fallback, statusCode: code);
  }

  @override
  String toString() => message;
}