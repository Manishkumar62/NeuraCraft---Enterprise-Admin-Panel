import '../../domain/entities/role_entity.dart';
import '../entities/module_permission_entity.dart';

abstract class RoleRepository {
  Future<List<RoleEntity>> getRoles();

  Future<RoleEntity> getRoleById(int id);

  Future<RoleEntity> createRole(Map<String, dynamic> data);

  Future<RoleEntity> updateRole(int id, Map<String, dynamic> data);

  Future<void> deleteRole(int id);

  Future<List<Map<String, dynamic>>> getDepartments();

  Future<List<ModulePermissionEntity>> getRolePermissions(int roleId);

  Future<void> updateRolePermissions(
    int roleId,
    List<Map<String, dynamic>> permissions,
  );
}