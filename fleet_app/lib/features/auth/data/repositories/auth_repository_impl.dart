import 'dart:convert';
import 'package:dio/dio.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../shared/utils/api_helper.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final TokenStorage _storage;
  final ApiClient _apiClient;

  AuthRepositoryImpl(this._remote, this._storage, this._apiClient);

  @override
  Future<({UserEntity user, String token})> login(String email, String password) async {
    try {
      // Set flag agar onUnauthorized tidak trigger saat proses login
      _apiClient.setAuthenticating(true);
      final result = await _remote.login(email, password);
      await _storage.saveToken(result.token);
      await _storage.saveUser(jsonEncode(result.user.toJson()));
      return (user: result.user as UserEntity, token: result.token);
    } on DioException catch (e) {
      throw ApiHelper.handleError(e);
    } finally {
      _apiClient.setAuthenticating(false);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remote.logout();
    } catch (_) {
      // Always clear storage even if API fails
    } finally {
      await _storage.clearAll();
    }
  }

  @override
  Future<UserEntity> me() async {
    try {
      return await _remote.me();
    } on DioException catch (e) {
      throw ApiHelper.handleError(e);
    }
  }

  @override
  Future<String?> getSavedToken() async {
    return await _storage.getToken();
  }
}
