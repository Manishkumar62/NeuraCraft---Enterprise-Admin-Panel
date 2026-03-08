import '../../domain/entities/role_entity.dart';
import '../../domain/entities/module_permission_entity.dart';

abstract class RoleState {}

class RoleInitial extends RoleState {}

class RoleLoading extends RoleState {}

class RoleLoaded extends RoleState {
  final List<RoleEntity> roles;

  RoleLoaded(this.roles);
}

class SingleRoleLoaded extends RoleState {
  final RoleEntity role;

  SingleRoleLoaded(this.role);
}

class RoleError extends RoleState {
  final String message;

  RoleError(this.message);
}

class RolePermissionsLoaded extends RoleState {
  final List<ModulePermissionEntity> modules;

  RolePermissionsLoaded(this.modules);
}