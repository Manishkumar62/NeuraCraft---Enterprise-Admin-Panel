import '../repositories/user_repository.dart';

class GetDepartments {
  final UserRepository repository;

  GetDepartments(this.repository);

  Future<List<Map<String, dynamic>>> call() {
    return repository.getDepartments();
  }
}