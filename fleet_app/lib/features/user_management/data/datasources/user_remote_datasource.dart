import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/managed_user_model.dart';

abstract class UserRemoteDataSource {
  Future<List<ManagedUserModel>> getUsers();
  Future<ManagedUserModel> createUser(Map<String, dynamic> data);
  Future<ManagedUserModel> updateUser(int id, Map<String, dynamic> data);
  Future<void> deleteUser(int id);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final ApiClient _apiClient;
  UserRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<ManagedUserModel>> getUsers() async {
    final r = await _apiClient.get(ApiConstants.users);
    final list = r.data['data'] as List;
    return list.map((e) => ManagedUserModel.fromJson(e)).toList();
  }

  @override
  Future<ManagedUserModel> createUser(Map<String, dynamic> data) async {
    final r = await _apiClient.post(ApiConstants.users, data: data);
    return ManagedUserModel.fromJson(r.data['data']);
  }

  @override
  Future<ManagedUserModel> updateUser(int id, Map<String, dynamic> data) async {
    final r = await _apiClient.put('${ApiConstants.users}/$id', data: data);
    return ManagedUserModel.fromJson(r.data['data']);
  }

  @override
  Future<void> deleteUser(int id) async {
    await _apiClient.delete('${ApiConstants.users}/$id');
  }
}
