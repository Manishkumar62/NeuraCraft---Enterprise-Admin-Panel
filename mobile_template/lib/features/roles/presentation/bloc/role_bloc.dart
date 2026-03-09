import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/services/permission_service.dart';
import '../../domain/usecases/create_role.dart';
import '../../domain/usecases/delete_role.dart';
import '../../domain/usecases/update_role.dart';
import '../../domain/usecases/get_roles.dart';
import '../../domain/usecases/get_role_by_id.dart';
import '../../domain/usecases/get_role_permissions.dart';
import '../../domain/usecases/update_role_permissions.dart';
import '../../domain/usecases/get_departments.dart';
import 'role_event.dart';
import 'role_state.dart';

class RoleBloc extends Bloc<RoleEvent, RoleState> {
  final GetAllRoles getRoles;
  final GetRoleById getRoleById;
  final CreateRole createRole;
  final UpdateRole updateRole;
  final DeleteRole deleteRole;
  final GetDepartmentsForRole getDepartments;
  final GetRolePermissions getRolePermissions;
  final UpdateRolePermissions updateRolePermissions;
  final PermissionService permissionService;

  RoleBloc({
    required this.getRoles,
    required this.getRoleById,
    required this.createRole,
    required this.updateRole,
    required this.deleteRole,
    required this.getDepartments,
    required this.getRolePermissions,
    required this.updateRolePermissions,
    required this.permissionService,
  }) : super(RoleInitial()) {
    on<LoadRoles>(_onLoadRoles);
    on<LoadRoleById>(_onLoadRoleById);
    on<CreateRoleEvent>(_onCreateRole);
    on<UpdateRoleEvent>(_onUpdateRole);
    on<DeleteRoleEvent>(_onDeleteRole);
    on<LoadDepartments>(_onLoadDepartments);
    on<LoadRolePermissions>(_onLoadPermissions);
    on<UpdateRolePermissionsEvent>(_onUpdatePermissions);
  }

  Future<void> _onLoadRoles(LoadRoles event, Emitter<RoleState> emit) async {
    if (!permissionService.canView('/roles')) {
      emit(RoleError('Permission denied'));
      return;
    }

    emit(RoleLoading());

    try {
      final roles = await getRoles();
      emit(RoleLoaded(roles));
    } catch (e) {
      emit(RoleError(e.toString()));
    }
  }

  Future<void> _onCreateRole(
    CreateRoleEvent event,
    Emitter<RoleState> emit,
  ) async {
    if (!permissionService.canAdd('/roles')) return;

    await createRole(event.data);
    add(LoadRoles());
  }

  Future<void> _onUpdateRole(
    UpdateRoleEvent event,
    Emitter<RoleState> emit,
  ) async {
    if (!permissionService.canEdit('/roles')) return;

    await updateRole(event.id, event.data);
    add(LoadRoles());
  }

  Future<void> _onDeleteRole(
    DeleteRoleEvent event,
    Emitter<RoleState> emit,
  ) async {
    if (!permissionService.canDelete('/roles')) return;

    await deleteRole(event.id);
    add(LoadRoles());
  }

  Future<void> _onLoadRoleById(
    LoadRoleById event,
    Emitter<RoleState> emit,
  ) async {
    emit(RoleLoading());

    try {
      final role = await getRoleById(event.id);
      emit(SingleRoleLoaded(role));
    } catch (e) {
      emit(RoleError(e.toString()));
    }
  }

  Future<void> _onLoadDepartments(
    LoadDepartments event,
    Emitter<RoleState> emit,
  ) async {
    try {
      final departments = await getDepartments();
      emit(DepartmentsLoaded(departments));
    } catch (e) {
      emit(RoleError(e.toString()));
    }
  }

  Future<void> _onLoadPermissions(
    LoadRolePermissions event,
    Emitter<RoleState> emit,
  ) async {
    emit(RoleLoading());

    try {
      final modules = await getRolePermissions(event.roleId);
      emit(RolePermissionsLoaded(modules));
    } catch (e) {
      emit(RoleError(e.toString()));
    }
  }

  Future<void> _onUpdatePermissions(
    UpdateRolePermissionsEvent event,
    Emitter<RoleState> emit,
  ) async {
    await updateRolePermissions(event.roleId, event.permissions);
    add(LoadRolePermissions(event.roleId));
  }
}
