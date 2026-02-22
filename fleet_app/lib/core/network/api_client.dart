import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/app_constants.dart';
import '../storage/token_storage.dart';

class ApiClient {
  late final Dio _dio;
  final TokenStorage _tokenStorage;
  final Function()? onUnauthorized;

  ApiClient(this._tokenStorage, {this.onUnauthorized}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _tokenStorage.clearAll();
            onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );

    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
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
    Options? options,
  }) async {
    return await _dio.post(path, data: data, options: options);
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    return await _dio.put(path, data: data, options: options);
  }

  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }

  Future<Response> postMultipart(
    String path, {
    required FormData formData,
  }) async {
    return await _dio.post(
      path,
      data: formData,
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
      ),
    );
  }

  Future<Response> putMultipart(
    String path, {
    required FormData formData,
  }) async {
    return await _dio.post(
      '$path?_method=PUT',
      data: formData,
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
      ),
    );
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  factory ApiException.fromDioError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      String message = 'Terjadi kesalahan';
      Map<String, dynamic>? errors;

      if (data is Map<String, dynamic>) {
        message = data['message'] ?? message;
        if (data['errors'] != null) {
          errors = Map<String, dynamic>.from(data['errors']);
        }
      }

      return ApiException(
        message: message,
        statusCode: e.response!.statusCode,
        errors: errors,
      );
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(message: 'Koneksi timeout. Periksa jaringan Anda.');
      case DioExceptionType.connectionError:
        return ApiException(message: 'Tidak dapat terhubung ke server.');
      default:
        return ApiException(message: 'Terjadi kesalahan jaringan.');
    }
  }

  String get firstError {
    if (errors == null || errors!.isEmpty) return message;
    final firstKey = errors!.keys.first;
    final val = errors![firstKey];
    if (val is List && val.isNotEmpty) return val.first.toString();
    return val.toString();
  }
}