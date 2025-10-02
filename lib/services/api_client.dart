import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_storage.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.body});

  final String message;
  final int? statusCode;
  final dynamic body;

  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, message: $message, body: $body)';
}

class ApiClient {
  ApiClient({
    required String baseUrl,
    required AuthStorage authStorage,
    http.Client? httpClient,
  })  : _baseUrl = baseUrl,
        _authStorage = authStorage,
        _httpClient = httpClient ?? http.Client();

  final String _baseUrl;
  final AuthStorage _authStorage;
  final http.Client _httpClient;

  Future<dynamic> get(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    return _send(
      'GET',
      path,
      queryParameters: queryParameters,
    );
  }

  Future<dynamic> post(
    String path, {
    Map<String, String>? queryParameters,
    Object? body,
  }) async {
    return _send(
      'POST',
      path,
      queryParameters: queryParameters,
      body: body,
    );
  }

  Future<dynamic> patch(
    String path, {
    Map<String, String>? queryParameters,
    Object? body,
  }) async {
    return _send(
      'PATCH',
      path,
      queryParameters: queryParameters,
      body: body,
    );
  }

  Future<dynamic> delete(
    String path, {
    Map<String, String>? queryParameters,
    Object? body,
  }) async {
    return _send(
      'DELETE',
      path,
      queryParameters: queryParameters,
      body: body,
    );
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, String>? queryParameters,
    Object? body,
  }) async {
    final token = await _authStorage.readToken();
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final uri = _buildUri(path, queryParameters);

    http.Response response;
    try {
      switch (method) {
        case 'GET':
          response = await _httpClient.get(uri, headers: headers);
          break;
        case 'POST':
          response = await _httpClient.post(
            uri,
            headers: headers,
            body: body == null ? null : jsonEncode(body),
          );
          break;
        case 'PATCH':
          response = await _httpClient.patch(
            uri,
            headers: headers,
            body: body == null ? null : jsonEncode(body),
          );
          break;
        case 'DELETE':
          response = await _httpClient.delete(
            uri,
            headers: headers,
            body: body == null ? null : jsonEncode(body),
          );
          break;
        default:
          throw ApiException('Unsupported HTTP method: $method');
      }
    } catch (error) {
      throw ApiException('Failed to connect to server: $error');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      try {
        return jsonDecode(response.body);
      } catch (_) {
        return response.body;
      }
    }

    dynamic errorBody;
    if (response.body.isNotEmpty) {
      try {
        errorBody = jsonDecode(response.body);
      } catch (_) {
        errorBody = response.body;
      }
    }

    throw ApiException(
      'Request failed with status ${response.statusCode}',
      statusCode: response.statusCode,
      body: errorBody,
    );
  }

  Uri _buildUri(String path, Map<String, String>? queryParameters) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$_baseUrl$normalizedPath');
    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }
    return uri.replace(queryParameters: {
      ...uri.queryParameters,
      ...queryParameters,
    });
  }

  void close() {
    _httpClient.close();
  }
}
