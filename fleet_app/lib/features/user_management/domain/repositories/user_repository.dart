import '../../domain/entities/managed_user_entity.dart';

abstract class UserRepository {
  Future<List<ManagedUserEntity>> getUsers();
  Future<ManagedUserEntity> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
  });
  Future<ManagedUserEntity> updateUser(int id, {
    String? name,
    String? email,
    String? password,
    String? role,
  });
  Future<void> deleteUser(int id);
}
