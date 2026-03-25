import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<({UserEntity user, String token})> login(String email, String password);
  Future<void> logout();
  Future<UserEntity> me();
  Future<String?> getSavedToken();
}
