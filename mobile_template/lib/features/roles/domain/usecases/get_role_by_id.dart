import '../entities/role_entity.dart';
import '../repositories/role_repository.dart';

class GetRoleById {
  final RoleRepository repository;

  GetRoleById(this.repository);

  Future<RoleEntity> call(int id) {
    return repository.getRoleById(id);
  }
}