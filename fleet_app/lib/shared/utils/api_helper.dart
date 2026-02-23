import 'package:dio/dio.dart';
import 'failure.dart';

class ApiHelper {
  static Failure handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const NetworkFailure('Tidak dapat terhubung ke server. Periksa koneksi internet.');
    }

    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    if (statusCode == 401) {
      return const UnauthorizedFailure();
    }

    if (statusCode == 422) {
      final errors = _parseValidationErrors(data);
      final firstMessage = errors.values.isNotEmpty ? errors.values.first.first : 'Validasi gagal';
      return ValidationFailure(firstMessage, errors: errors);
    }

    final message = data is Map ? data['message'] ?? 'Terjadi kesalahan' : 'Terjadi kesalahan';
    return ServerFailure(message.toString());
  }

  static Map<String, List<String>> _parseValidationErrors(dynamic data) {
    final result = <String, List<String>>{};
    if (data is Map && data['errors'] is Map) {
      final errors = data['errors'] as Map;
      errors.forEach((key, value) {
        if (value is List) {
          result[key.toString()] = value.map((e) => e.toString()).toList();
        }
      });
    }
    return result;
  }
}
