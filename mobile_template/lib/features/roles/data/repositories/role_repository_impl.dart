
import '../datasources/role_remote_ds.dart';
import '../../domain/entities/role_entity.dart';
import '../../domain/repositories/role_repository.dart';
import '../../domain/entities/module_permission_entity.dart';

class RoleRepositoryImpl implements RoleRepository {
  final RoleRemoteDataSource remote;

  RoleRepositoryImpl(this.remote);

  @override
  Future<List<RoleEntity>> getRoles() {
    return remote.getRoles();
  }

  @override
  Future<RoleEntity> getRoleById(int id) {
    return remote.getRoleById(id);
  }

  @override
  Future<RoleEntity> createRole(Map<String, dynamic> data) {
    return remote.createRole(data);
  }

  @override
  Future<RoleEntity> updateRole(int id, Map<String, dynamic> data) {
    return remote.updateRole(id, data);
  }

  @override
  Future<void> deleteRole(int id) {
    return remote.deleteRole(id);
  }

  @override
  Future<List<ModulePermissionEntity>> getRolePermissions(int roleId) {
    return remote.getRolePermissions(roleId);
  }

  @override
  Future<void> updateRolePermissions(
    int roleId,
    List<Map<String, dynamic>> permissions,
  ) {
    return remote.updateRolePermissions(roleId, permissions);
  }
}
