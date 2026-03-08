import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/permission_service.dart';

import '../../domain/usecases/get_users.dart';
import '../../domain/usecases/get_user_by_id.dart';
import '../../domain/usecases/create_user.dart';
import '../../domain/usecases/update_user.dart';
import '../../domain/usecases/delete_user.dart';
import '../../domain/usecases/get_departments.dart';
import '../../domain/usecases/get_roles.dart';

import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final GetUsers getUsers;
  final GetUserById getUserById;
  final CreateUser createUser;
  final UpdateUser updateUser;
  final DeleteUser deleteUser;
  final GetRolesForUser getRoles;
  final GetDepartments getDepartments;
  final PermissionService permissionService;

  UserBloc({
    required this.getUsers,
    required this.getUserById,
    required this.createUser,
    required this.updateUser,
    required this.deleteUser,
    required this.getRoles,
    required this.getDepartments,
    required this.permissionService,
  }) : super(UserInitial()) {
    on<LoadUsers>(_onLoadUsers);
    on<CreateUserEvent>(_onCreateUser);
    on<UpdateUserEvent>(_onUpdateUser);
    on<DeleteUserEvent>(_onDeleteUser);
    on<LoadUserById>(_onFetchUserById);
    on<LoadRoles>(_onLoadRoles);
    on<LoadDepartments>(_onLoadDepartments);
  }

  Future<void> _onLoadUsers(LoadUsers event, Emitter<UserState> emit) async {
    if (!permissionService.canView('/users')) {
      emit(UserError('Permission denied'));
      return;
    }

    emit(UserLoading());

    try {
      final users = await getUsers();
      emit(UserListLoaded(users));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onCreateUser(
    CreateUserEvent event,
    Emitter<UserState> emit,
  ) async {
    if (!permissionService.canAdd('/users')) return;

    await createUser(event.data);
    add(LoadUsers());
  }

  Future<void> _onUpdateUser(
    UpdateUserEvent event,
    Emitter<UserState> emit,
  ) async {
    if (!permissionService.canEdit('/users')) return;

    await updateUser(event.id, event.data);
    add(LoadUsers());
  }

  Future<void> _onDeleteUser(
    DeleteUserEvent event,
    Emitter<UserState> emit,
  ) async {
    if (!permissionService.canDelete('/users')) return;

    await deleteUser(event.id);
    add(LoadUsers());
  }

  Future<void> _onFetchUserById(
    LoadUserById event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());

    try {
      final user = await getUserById(event.id);
      emit(SingleUserLoaded(user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onLoadRoles(LoadRoles event, Emitter<UserState> emit) async {
    try {
      final roles = await getRoles();

      emit(RolesLoaded(roles));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onLoadDepartments(
    LoadDepartments event,
    Emitter<UserState> emit,
  ) async {
    try {
      final departments = await getDepartments();

      emit(DepartmentsLoaded(departments));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}
