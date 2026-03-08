import '../repositories/user_repository.dart';

class GetRolesForUser {
  final UserRepository repository;

  GetRolesForUser(this.repository);

  Future<List<Map<String, dynamic>>> call() {
    return repository.getRoles();
  }
}