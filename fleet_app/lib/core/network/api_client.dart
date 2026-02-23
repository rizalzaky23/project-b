import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/token_storage.dart';

class ApiClient {
  late final Dio _dio;
  final TokenStorage _tokenStorage;
  final void Function()? onUnauthorized;

  // Flag untuk mencegah logout loop saat sedang proses login
  bool _isAuthenticating = false;

  ApiClient(this._tokenStorage, {this.onUnauthorized}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
        headers: {'Accept': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Hanya trigger onUnauthorized jika:
          // - Status 401
          // - Bukan sedang proses login/register (menghindari loop)
          if (e.response?.statusCode == 401 && !_isAuthenticating) {
            final path = e.requestOptions.path;
            final isAuthEndpoint = path.contains('/auth/login') ||
                path.contains('/auth/register');
            if (!isAuthEndpoint) {
              onUnauthorized?.call();
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  void setAuthenticating(bool value) {
    _isAuthenticating = value;
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.post(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.put(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.delete(path, queryParameters: queryParameters);
  }
}
