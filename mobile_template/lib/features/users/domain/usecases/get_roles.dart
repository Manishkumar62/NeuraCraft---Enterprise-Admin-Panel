import '../repositories/user_repository.dart';

class GetRoles {
  final UserRepository repository;

  GetRoles(this.repository);

  Future<List<Map<String, dynamic>>> call() {
    return repository.getRoles();
  }
}