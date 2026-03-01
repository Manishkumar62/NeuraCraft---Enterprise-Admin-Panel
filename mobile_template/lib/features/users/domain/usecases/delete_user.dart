import '../repositories/user_repository.dart';

class DeleteUser {
  final UserRepository repository;

  DeleteUser(this.repository);

  Future<void> call(int id) {
    return repository.deleteUser(id);
  }
}