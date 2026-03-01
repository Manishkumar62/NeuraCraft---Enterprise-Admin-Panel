import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<List<UserEntity>> getUsers();

  Future<UserEntity> getUserById(int id);

  Future<UserEntity> createUser(Map<String, dynamic> data);

  Future<UserEntity> updateUser(int id, Map<String, dynamic> data);

  Future<void> deleteUser(int id);
}