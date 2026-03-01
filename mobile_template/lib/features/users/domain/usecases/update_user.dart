import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class UpdateUser {
  final UserRepository repository;

  UpdateUser(this.repository);

  Future<UserEntity> call(int id, Map<String, dynamic> data) {
    return repository.updateUser(id, data);
  }
}