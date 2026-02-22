import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import 'auth_model.dart';

class AuthRepository {
  final ApiClient Function() _apiFactory;
  final TokenStorage tokenStorage;

  AuthRepository(this._apiFactory, this.tokenStorage);

  Future<AuthResponse> login(String email, String password) async {
    final api = _apiFactory();
    final resp = await api.post('/auth/login', data: {'email': email, 'password': password});
    
    if (resp.statusCode == 200 && resp.data is Map<String, dynamic>) {
      try {
        final responseMap = resp.data as Map<String, dynamic>;
        
        // Extract the nested data object
        final dataObj = responseMap['data'];
        if (dataObj == null || dataObj is! Map<String, dynamic>) {
          throw Exception('Invalid response structure');
        }
        
        final token = dataObj['token'];
        if (token == null || token is! String) {
          throw Exception('Token not found in response');
        }
        
        final user = dataObj['user'];
        
        await tokenStorage.writeToken(token);
        return AuthResponse(token: token, user: user as Map<String, dynamic>?);
      } catch (e) {
        throw Exception('Failed to parse login response: $e');
      }
    }
    
    // Handle error responses
    String errorMessage = 'Login failed';
    if (resp.data is Map<String, dynamic>) {
      errorMessage = resp.data['message'] ?? errorMessage;
    }
    throw Exception(errorMessage);
  }

  Future<void> logout() async {
    final api = _apiFactory();
    try {
      await api.post('/auth/logout');
    } catch (_) {}
    await tokenStorage.deleteToken();
  }
}
