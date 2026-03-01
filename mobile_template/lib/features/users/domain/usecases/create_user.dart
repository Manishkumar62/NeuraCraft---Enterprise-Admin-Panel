import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class CreateUser {
  final UserRepository repository;

  CreateUser(this.repository);

  Future<UserEntity> call(Map<String, dynamic> data) {
    return repository.createUser(data);
  }
}