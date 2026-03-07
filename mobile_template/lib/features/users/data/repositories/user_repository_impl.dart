import '../datasources/user_remote_datasource.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<UserEntity>> getUsers() {
    return remoteDataSource.getUsers();
  }

  @override
  Future<UserEntity> getUserById(int id) {
    return remoteDataSource.getUserById(id);
  }

  @override
  Future<UserEntity> createUser(Map<String, dynamic> data) {
    return remoteDataSource.createUser(data);
  }

  @override
  Future<UserEntity> updateUser(int id, Map<String, dynamic> data) {
    return remoteDataSource.updateUser(id, data);
  }

  @override
  Future<void> deleteUser(int id) {
    return remoteDataSource.deleteUser(id);
  }

  @override
  Future<List<Map<String, dynamic>>> getRoles() {
    return remoteDataSource.getRoles();
  }

  @override
  Future<List<Map<String, dynamic>>> getDepartments() {
    return remoteDataSource.getDepartments();
  }
}
