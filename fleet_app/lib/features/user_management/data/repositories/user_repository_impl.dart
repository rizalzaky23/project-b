import '../../domain/entities/managed_user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _ds;
  UserRepositoryImpl(this._ds);

  @override
  Future<List<ManagedUserEntity>> getUsers() => _ds.getUsers();

  @override
  Future<ManagedUserEntity> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) =>
      _ds.createUser({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      });

  @override
  Future<ManagedUserEntity> updateUser(int id, {
    String? name,
    String? email,
    String? password,
    String? role,
  }) {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (password != null && password.isNotEmpty) data['password'] = password;
    if (role != null) data['role'] = role;
    return _ds.updateUser(id, data);
  }

  @override
  Future<void> deleteUser(int id) => _ds.deleteUser(id);
}
