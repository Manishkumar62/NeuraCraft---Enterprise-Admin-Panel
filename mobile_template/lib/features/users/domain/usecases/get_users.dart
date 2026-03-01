import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class GetUsers {
  final UserRepository repository;

  GetUsers(this.repository);

  Future<List<UserEntity>> call() {
    return repository.getUsers();
  }
}