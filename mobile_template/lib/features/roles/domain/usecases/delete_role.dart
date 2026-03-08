import '../repositories/role_repository.dart';

class DeleteRole {
  final RoleRepository repository;

  DeleteRole(this.repository);

  Future<void> call(int id) {
    return repository.deleteRole(id);
  }
}