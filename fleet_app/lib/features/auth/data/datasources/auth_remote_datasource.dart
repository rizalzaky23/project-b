import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<({UserModel user, String token})> login(String email, String password);
  Future<void> logout();
  Future<UserModel> me();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<({UserModel user, String token})> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    final data = response.data['data'];
    return (
      user: UserModel.fromJson(data['user']),
      token: data['token'] as String,
    );
  }

  @override
  Future<void> logout() async {
    await _apiClient.post(ApiConstants.logout);
  }

  @override
  Future<UserModel> me() async {
    final response = await _apiClient.get(ApiConstants.me);
    return UserModel.fromJson(response.data['data']);
  }
}
