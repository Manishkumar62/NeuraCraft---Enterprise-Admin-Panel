import '../entities/role_entity.dart';
import '../repositories/role_repository.dart';

class GetAllRoles {
  final RoleRepository repository;

  GetAllRoles(this.repository);

  Future<List<RoleEntity>> call() {
    return repository.getRoles();
  }
}