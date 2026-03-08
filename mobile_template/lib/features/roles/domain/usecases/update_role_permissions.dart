import '../repositories/role_repository.dart';

class UpdateRolePermissions {
  final RoleRepository repository;

  UpdateRolePermissions(this.repository);

  Future<void> call(
    int roleId,
    List<Map<String, dynamic>> permissions,
  ) {
    return repository.updateRolePermissions(roleId, permissions);
  }
}