// lib/core/network/api_service.dart

import 'package:dio/dio.dart';
import 'api_client.dart';

class ApiService {
  final ApiClient _client;

  ApiService(this._client);

  /// GET
  Future<Response> get(String path, {Map<String, dynamic>? query}) async {
    return await _client.dio.get(
      path,
      queryParameters: query,
    );
  }

  /// POST
  Future<Response> post(String path, {dynamic data}) async {
    return await _client.dio.post(
      path,
      data: data,
    );
  }

  /// PUT
  Future<Response> put(String path, {dynamic data}) async {
    return await _client.dio.put(
      path,
      data: data,
    );
  }

  /// DELETE
  Future<Response> delete(String path, {dynamic data}) async {
    return await _client.dio.delete(
      path,
      data: data,
    );
  }
}