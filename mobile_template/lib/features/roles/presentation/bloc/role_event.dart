abstract class RoleEvent {}

class LoadRoles extends RoleEvent {}

class LoadRoleById extends RoleEvent {
  final int id;
  LoadRoleById(this.id);
}

class CreateRoleEvent extends RoleEvent {
  final Map<String, dynamic> data;
  CreateRoleEvent(this.data);
}

class UpdateRoleEvent extends RoleEvent {
  final int id;
  final Map<String, dynamic> data;
  UpdateRoleEvent(this.id, this.data);
}

class DeleteRoleEvent extends RoleEvent {
  final int id;
  DeleteRoleEvent(this.id);
}

class LoadRolePermissions extends RoleEvent {
  final int roleId;

  LoadRolePermissions(this.roleId);
}

class UpdateRolePermissionsEvent extends RoleEvent {
  final int roleId;
  final List<Map<String, dynamic>> permissions;

  UpdateRolePermissionsEvent(this.roleId, this.permissions);
}