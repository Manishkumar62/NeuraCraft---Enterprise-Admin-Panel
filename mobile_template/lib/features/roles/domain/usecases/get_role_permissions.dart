import '../entities/module_permission_entity.dart';
import '../repositories/role_repository.dart';

class GetRolePermissions {
  final RoleRepository repository;

  GetRolePermissions(this.repository);

  Future<List<ModulePermissionEntity>> call(int roleId) {
    return repository.getRolePermissions(roleId);
  }
}