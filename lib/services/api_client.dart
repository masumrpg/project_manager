import 'package:dio/dio.dart';
import 'auth_storage.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.body});

  final String? message;
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
  }) : _dio = Dio(BaseOptions(baseUrl: baseUrl)) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await authStorage.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Accept'] = 'application/json';
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );
  }

  final Dio _dio;

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _request(
      () => _dio.get(path, queryParameters: queryParameters),
    );
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? body,
  }) async {
    return _request(
      () => _dio.post(path, queryParameters: queryParameters, data: body),
    );
  }

  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? body,
  }) async {
    return _request(
      () => _dio.patch(path, queryParameters: queryParameters, data: body),
    );
  }

  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? body,
  }) async {
    return _request(
      () => _dio.delete(path, queryParameters: queryParameters, data: body),
    );
  }

  Future<dynamic> _request(Future<Response<dynamic>> Function() request) async {
    try {
      final response = await request();
      return response.data;
    } on DioException catch (e) {
      throw ApiException(
        e.message,
        statusCode: e.response?.statusCode,
        body: e.response?.data,
      );
    } catch (e) {
      throw ApiException('An unexpected error occurred: $e');
    }
  }

  void close() {
    _dio.close();
  }
}
