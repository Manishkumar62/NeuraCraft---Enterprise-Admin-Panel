import '../repositories/role_repository.dart';

class GetDepartmentsForRole {
  final RoleRepository repository;

  GetDepartmentsForRole(this.repository);

  Future<List<Map<String, dynamic>>> call() {
    return repository.getDepartments();
  }
}