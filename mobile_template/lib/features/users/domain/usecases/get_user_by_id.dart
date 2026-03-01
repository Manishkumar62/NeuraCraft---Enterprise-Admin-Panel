import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class GetUserById {
  final UserRepository repository;

  GetUserById(this.repository);

  Future<UserEntity> call(int id) {
    return repository.getUserById(id);
  }
}